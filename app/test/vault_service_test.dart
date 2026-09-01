import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:app/services/vault_service.dart';

void main() {
  group('VaultService Local Filesystem Engine', () {
    late Directory tempDir;
    late VaultService service;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('spinel_flutter_test_');
      service = VaultService();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('creates note and scans directory hierarchy', () async {
      final doc = await service.createNote(
        tempDir.path,
        '01_Daily/today.md',
        'Daily Reflection',
      );

      expect(doc.title, equals('Daily Reflection'));
      expect(await File(doc.filePath).exists(), isTrue);

      final nodes = await service.scanVault(tempDir.path);
      expect(nodes.length, equals(1));
      expect(nodes.first.name, equals('01_Daily'));
      expect(nodes.first.isDirectory, isTrue);
      expect(nodes.first.children.first.name, equals('today.md'));
    });

    test('saves note atomically without data loss', () async {
      final doc = await service.createNote(
        tempDir.path,
        'notes/sample.md',
        'Initial Title',
      );

      doc.body = '\n# Updated Content\nNew lines added.';
      doc.frontmatter['author'] = 'Riccardo';
      await service.saveNoteAtomic(doc);

      final reloaded = await service.loadNote(doc.filePath, tempDir.path);
      expect(reloaded, isNotNull);
      expect(reloaded!.body, contains('Updated Content'));
      expect(reloaded.frontmatter['author'], equals('Riccardo'));
    });

    test('handles non-existent vault gracefully', () async {
      final nonExistentPath = '/tmp/non_existent_vault_${DateTime.now().millisecondsSinceEpoch}';
      final nodes = await service.scanVault(nonExistentPath);
      expect(nodes, isEmpty);
    });
  });
}
