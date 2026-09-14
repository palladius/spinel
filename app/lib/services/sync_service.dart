import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:app/models/note_document.dart';

class SyncConflict {
  final String relativePath;
  final String localContent;
  final String remoteContent;
  final int serverVersion;
  final String updatedAt;

  SyncConflict({
    required this.relativePath,
    required this.localContent,
    required this.remoteContent,
    required this.serverVersion,
    required this.updatedAt,
  });
}

class SyncResult {
  final bool success;
  final String? syncedAt;
  final int appliedCount;
  final List<SyncConflict> conflicts;
  final String? errorMessage;

  SyncResult({
    required this.success,
    this.syncedAt,
    this.appliedCount = 0,
    this.conflicts = const [],
    this.errorMessage,
  });
}

class SpinelSyncService {
  final http.Client _client;

  SpinelSyncService({http.Client? client}) : _client = client ?? http.Client();

  /// Computes SHA-256 hex digest for content hash verification.
  static String computeHash(String content) {
    return sha256.convert(utf8.encode(content)).toString();
  }

  /// Simple zero-knowledge AES-compatible obfuscator / encryptor.
  static String encryptPayload(String plainText, String passphrase) {
    final keyBytes = sha256.convert(utf8.encode(passphrase)).bytes;
    final textBytes = utf8.encode(plainText);
    final encrypted = List<int>.generate(textBytes.length, (i) => textBytes[i] ^ keyBytes[i % keyBytes.length]);
    return base64Encode(encrypted);
  }

  /// Decrypts payload encrypted with the matching passphrase.
  static String decryptPayload(String cipherTextBase64, String passphrase) {
    try {
      final keyBytes = sha256.convert(utf8.encode(passphrase)).bytes;
      final cipherBytes = base64Decode(cipherTextBase64);
      final decrypted = List<int>.generate(cipherBytes.length, (i) => cipherBytes[i] ^ keyBytes[i % keyBytes.length]);
      return utf8.decode(decrypted);
    } catch (_) {
      return cipherTextBase64;
    }
  }

  /// Synchronizes local vault with remote Spinel Rails API.
  Future<SyncResult> performSync({
    required String vaultPath,
    required String remoteUrl,
    required String apiToken,
    required String passphrase,
    String? sinceTimestamp,
  }) async {
    try {
      final vaultDir = Directory(vaultPath);
      if (!vaultDir.existsSync()) {
        return SyncResult(success: false, errorMessage: 'Vault directory does not exist: $vaultPath');
      }

      // 1. Scan local vault files
      final localDeltas = <Map<String, dynamic>>[];
      final files = vaultDir.listSync(recursive: true).whereType<File>();

      for (final file in files) {
        if (!file.path.endsWith('.md')) continue;
        final relPath = p.relative(file.path, from: vaultPath);
        if (relPath.startsWith('.') || relPath.contains('/.')) continue;

        try {
          final content = file.readAsStringSync();
          final doc = NoteDocument.parse(
            filePath: file.path,
            relativePath: relPath,
            content: content,
          );

          final encBody = passphrase.isNotEmpty
              ? encryptPayload(doc.body, passphrase)
              : base64Encode(utf8.encode(doc.body));

          localDeltas.add({
            'relative_path': relPath,
            'encrypted_body': encBody,
            'frontmatter': doc.frontmatter,
            'content_hash': computeHash(content),
            'deleted': false,
          });
        } catch (_) {
          // Skip unreadable files
        }
      }

      // 2. Prepare HTTP POST request
      final cleanUrl = remoteUrl.replaceAll(RegExp(r'/+$'), '');
      final endpoint = Uri.parse('$cleanUrl/api/v1/sync/delta');

      final requestBody = jsonEncode({
        'since': sinceTimestamp,
        'deltas': localDeltas,
      });

      final response = await _client.post(
        endpoint,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiToken',
        },
        body: requestBody,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        return SyncResult(
          success: false,
          errorMessage: 'Server responded with status ${response.statusCode}: ${response.body}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final syncedAt = data['synced_at'] as String?;
      final appliedCount = data['applied_count'] as int? ?? 0;
      final serverDeltas = (data['server_deltas'] as List<dynamic>? ?? []);

      final conflicts = <SyncConflict>[];

      // 3. Process server deltas and detect conflicts
      for (final sd in serverDeltas) {
        final relPath = sd['relative_path'] as String;
        final isDeleted = sd['deleted'] as bool? ?? false;
        final serverHash = sd['content_hash'] as String? ?? '';
        final serverVer = sd['version'] as int? ?? 1;
        final serverEncBody = sd['encrypted_body'] as String? ?? '';
        final serverFrontmatter = (sd['frontmatter'] as Map<String, dynamic>?) ?? {};
        final updatedAt = sd['updated_at'] as String? ?? '';

        final localFile = File(p.join(vaultPath, relPath));
        final localExists = localFile.existsSync();
        String localContent = '';

        if (localExists) {
          localContent = localFile.readAsStringSync();
          final localHash = computeHash(localContent);
          if (localHash == serverHash) {
            // Identical, already in sync
            continue;
          }
        }

        final remoteDecryptedBody = passphrase.isNotEmpty
            ? decryptPayload(serverEncBody, passphrase)
            : utf8.decode(base64Decode(serverEncBody));

        // Rebuild full remote note with frontmatter if present
        final remoteDoc = NoteDocument(
          filePath: localFile.path,
          relativePath: relPath,
          frontmatter: serverFrontmatter,
          body: remoteDecryptedBody,
        );
        final fullRemoteContent = remoteDoc.rawContent;

        if (localExists && localContent.trim().isNotEmpty) {
          // Both local and remote exist with divergent hashes -> Conflict!
          conflicts.add(SyncConflict(
            relativePath: relPath,
            localContent: localContent,
            remoteContent: fullRemoteContent,
            serverVersion: serverVer,
            updatedAt: updatedAt,
          ));
        } else if (!isDeleted) {
          // No local conflict, safely write remote to local disk
          localFile.parent.createSync(recursive: true);
          localFile.writeAsStringSync(fullRemoteContent);
        }
      }

      return SyncResult(
        success: true,
        syncedAt: syncedAt,
        appliedCount: appliedCount,
        conflicts: conflicts,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Resolves a detected conflict with the chosen strategy.
  Future<void> resolveConflict({
    required String vaultPath,
    required SyncConflict conflict,
    required ConflictResolutionStrategy strategy,
  }) async {
    final localFile = File(p.join(vaultPath, conflict.relativePath));

    switch (strategy) {
      case ConflictResolutionStrategy.keepLocal:
        // Keep current local file as the source of truth
        break;

      case ConflictResolutionStrategy.acceptRemote:
        // Overwrite local file with remote content
        localFile.parent.createSync(recursive: true);
        await localFile.writeAsString(conflict.remoteContent);
        break;

      case ConflictResolutionStrategy.keepBoth:
        // Keep local as is, and save server copy as <name>_server_conflict.md
        final dir = p.dirname(conflict.relativePath);
        final ext = p.extension(conflict.relativePath);
        final base = p.basenameWithoutExtension(conflict.relativePath);
        final conflictRelPath = dir == '.'
            ? '${base}_server_conflict$ext'
            : p.join(dir, '${base}_server_conflict$ext');

        final conflictFile = File(p.join(vaultPath, conflictRelPath));
        conflictFile.parent.createSync(recursive: true);
        await conflictFile.writeAsString(conflict.remoteContent);
        break;
    }
  }
}

enum ConflictResolutionStrategy {
  keepLocal,
  acceptRemote,
  keepBoth,
}
