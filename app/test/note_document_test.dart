import 'package:flutter_test/flutter_test.dart';
import 'package:app/models/note_document.dart';

void main() {
  group('NoteDocument Parser & Serializer', () {
    test('parses YAML frontmatter and body correctly', () {
      const raw = '''---
title: "Project Alpha"
author: "Riccardino"
tags:
  - sre
  - gemini
---

# Hello World
This is markdown content.
''';

      final doc = NoteDocument.parse(
        filePath: '/vault/notes/test.md',
        relativePath: 'notes/test.md',
        content: raw,
      );

      expect(doc.title, equals('Project Alpha'));
      expect(doc.frontmatter['author'], equals('Riccardino'));
      expect(doc.frontmatter['tags'], contains('sre'));
      expect(doc.body, contains('# Hello World'));
    });

    test('serializes back to raw markdown with frontmatter', () {
      final doc = NoteDocument(
        filePath: '/vault/test.md',
        relativePath: 'test.md',
        frontmatter: {'title': 'Sample', 'author': 'Riccardo'},
        body: '\n# Note Body',
      );

      final raw = doc.toRawContent();
      expect(raw, startsWith('---\n'));
      expect(raw, contains('title: "Sample"'));
      expect(raw, contains('author: "Riccardo"'));
      expect(raw, contains('# Note Body'));
    });
  });
}
