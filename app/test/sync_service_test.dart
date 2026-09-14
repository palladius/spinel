import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:app/services/sync_service.dart';
import 'package:app/state/sync_provider.dart';
import 'package:app/state/vault_provider.dart';
import 'package:app/widgets/sync_dialog.dart';
import 'package:app/widgets/conflict_resolution_dialog.dart';

void main() {
  group('SpinelSyncService Core Logic', () {
    test('computeHash produces valid 64-char hex SHA-256', () {
      final hash1 = SpinelSyncService.computeHash('Hello Spinel');
      final hash2 = SpinelSyncService.computeHash('Hello Spinel');
      final hash3 = SpinelSyncService.computeHash('Different Content');

      expect(hash1.length, equals(64));
      expect(hash1, equals(hash2));
      expect(hash1, isNot(equals(hash3)));
    });

    test('encryptPayload and decryptPayload roundtrip', () {
      const plainText = '# Top Secret Vault Note\nWith AES payload.';
      const passphrase = 'my-gemstone-secret';

      final encrypted = SpinelSyncService.encryptPayload(plainText, passphrase);
      expect(encrypted, isNot(equals(plainText)));

      final decrypted = SpinelSyncService.decryptPayload(encrypted, passphrase);
      expect(decrypted, equals(plainText));
    });

    test('performSync successfully communicates with mock server and processes deltas', () async {
      final tempDir = Directory.systemTemp.createTempSync('spinel_sync_test_');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      // Create a local note
      final noteFile = File('${tempDir.path}/note1.md');
      noteFile.writeAsStringSync('# Local Note\nLocal content.');

      final mockClient = MockClient((request) async {
        expect(request.url.path, equals('/api/v1/sync/delta'));
        expect(request.headers['Authorization'], equals('Bearer test-token-123'));

        final responsePayload = {
          'synced_at': '2026-09-14T10:00:00Z',
          'applied_count': 1,
          'server_deltas': [
            {
              'id': 'remote-uuid-1',
              'relative_path': 'remote_note.md',
              'encrypted_body': base64Encode(utf8.encode('Body from remote cloud.')),
              'frontmatter': {'title': 'Remote Note'},
              'content_hash': SpinelSyncService.computeHash('Body from remote cloud.'),
              'version': 2,
              'deleted': false,
              'updated_at': '2026-09-14T09:59:00Z',
            }
          ]
        };

        return http.Response(jsonEncode(responsePayload), 200, headers: {'content-type': 'application/json'});
      });

      final syncService = SpinelSyncService(client: mockClient);
      final result = await syncService.performSync(
        vaultPath: tempDir.path,
        remoteUrl: 'https://api.spinel.test',
        apiToken: 'test-token-123',
        passphrase: '',
      );

      expect(result.success, isTrue);
      expect(result.appliedCount, equals(1));
      expect(result.syncedAt, equals('2026-09-14T10:00:00Z'));
      expect(result.conflicts, isEmpty);

      // Verify remote note written to disk
      final newFile = File('${tempDir.path}/remote_note.md');
      expect(newFile.existsSync(), isTrue);
      expect(newFile.readAsStringSync().contains('Body from remote cloud.'), isTrue);
    });

    test('performSync flags conflict when local and remote differ', () async {
      final tempDir = Directory.systemTemp.createTempSync('spinel_conflict_test_');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      // Create a local note
      final noteFile = File('${tempDir.path}/conflict_note.md');
      noteFile.writeAsStringSync('# Local Version\nModified locally.');

      final mockClient = MockClient((request) async {
        final responsePayload = {
          'synced_at': '2026-09-14T10:00:00Z',
          'applied_count': 0,
          'server_deltas': [
            {
              'id': 'remote-uuid-2',
              'relative_path': 'conflict_note.md',
              'encrypted_body': base64Encode(utf8.encode('# Remote Version\nModified on phone.')),
              'frontmatter': {'title': 'Remote Title'},
              'content_hash': 'server_hash_123',
              'version': 3,
              'deleted': false,
              'updated_at': '2026-09-14T09:55:00Z',
            }
          ]
        };

        return http.Response(jsonEncode(responsePayload), 200, headers: {'content-type': 'application/json'});
      });

      final syncService = SpinelSyncService(client: mockClient);
      final result = await syncService.performSync(
        vaultPath: tempDir.path,
        remoteUrl: 'https://api.spinel.test',
        apiToken: 'test-token-123',
        passphrase: '',
      );

      expect(result.success, isTrue);
      expect(result.conflicts.length, equals(1));
      expect(result.conflicts.first.relativePath, equals('conflict_note.md'));
      expect(result.conflicts.first.localContent.contains('Modified locally.'), isTrue);
      expect(result.conflicts.first.remoteContent.contains('Modified on phone.'), isTrue);
    });

    test('resolveConflict handles keepBoth strategy by creating _server_conflict.md', () async {
      final tempDir = Directory.systemTemp.createTempSync('spinel_resolve_test_');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final noteFile = File('${tempDir.path}/daily.md');
      noteFile.writeAsStringSync('Local text');

      final conflict = SyncConflict(
        relativePath: 'daily.md',
        localContent: 'Local text',
        remoteContent: 'Server text',
        serverVersion: 2,
        updatedAt: '2026-09-14T08:00:00Z',
      );

      final service = SpinelSyncService();
      await service.resolveConflict(
        vaultPath: tempDir.path,
        conflict: conflict,
        strategy: ConflictResolutionStrategy.keepBoth,
      );

      expect(File('${tempDir.path}/daily.md').readAsStringSync(), equals('Local text'));
      final conflictFile = File('${tempDir.path}/daily_server_conflict.md');
      expect(conflictFile.existsSync(), isTrue);
      expect(conflictFile.readAsStringSync(), equals('Server text'));
    });
  });

  group('Sync UI Dialogs', () {
    testWidgets('SyncDialog renders configuration inputs and Sync button', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: SyncDialog(),
            ),
          ),
        ),
      );

      expect(find.text('Cloud Sync Settings'), findsOneWidget);
      expect(find.text('Remote Sync Server URL:'), findsOneWidget);
      expect(find.text('Vault API Token:'), findsOneWidget);
      expect(find.text('Zero-Knowledge Encryption Passphrase:'), findsOneWidget);
      expect(find.text('Sync Now'), findsOneWidget);
    });

    testWidgets('ConflictResolutionDialog renders side-by-side local vs remote comparison', (tester) async {
      final conflict = SyncConflict(
        relativePath: 'architecture.md',
        localContent: '# Local Architecture\nCustom local changes.',
        remoteContent: '# Remote Architecture\nChanges made on mobile.',
        serverVersion: 4,
        updatedAt: '2026-09-14T10:30:00Z',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ConflictResolutionDialog(conflict: conflict),
            ),
          ),
        ),
      );

      expect(find.text('Sync Conflict Detected'), findsOneWidget);
      expect(find.text('Local Version (On Disk)'), findsOneWidget);
      expect(find.text('Server Version (Remote Cloud)'), findsOneWidget);
      expect(find.text('Keep Local'), findsOneWidget);
      expect(find.text('Accept Remote'), findsOneWidget);
      expect(find.text('Keep Both (Fork _conflict.md)'), findsOneWidget);
    });
  });
}
