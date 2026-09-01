import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:app/models/note_document.dart';

class VaultFileNode {
  final String path;
  final String relativePath;
  final String name;
  final bool isDirectory;
  final List<VaultFileNode> children;

  VaultFileNode({
    required this.path,
    required this.relativePath,
    required this.name,
    required this.isDirectory,
    List<VaultFileNode>? children,
  }) : children = children ?? [];
}

class VaultService {
  Future<List<VaultFileNode>> scanVault(String rootPath) async {
    final rootDir = Directory(rootPath);
    if (!await rootDir.exists()) {
      return [];
    }

    final nodes = <VaultFileNode>[];
    await _scanRecursive(rootDir, rootPath, nodes);
    _sortNodes(nodes);
    return nodes;
  }

  Future<void> _scanRecursive(Directory currentDir, String rootPath, List<VaultFileNode> parentList) async {
    final entities = await currentDir.list(followLinks: false).toList();

    for (final entity in entities) {
      final name = p.basename(entity.path);
      if (name.startsWith('.') && name != '.spinel') {
        continue; // Skip hidden folders
      }
      if (name == 'node_modules' || name == 'vendor') {
        continue;
      }

      final relPath = p.relative(entity.path, from: rootPath);

      if (entity is Directory) {
        final dirNode = VaultFileNode(
          path: entity.path,
          relativePath: relPath,
          name: name,
          isDirectory: true,
        );
        parentList.add(dirNode);
        await _scanRecursive(entity, rootPath, dirNode.children);
      } else if (entity is File && entity.path.toLowerCase().endsWith('.md')) {
        parentList.add(VaultFileNode(
          path: entity.path,
          relativePath: relPath,
          name: name,
          isDirectory: false,
        ));
      }
    }
  }

  void _sortNodes(List<VaultFileNode> nodes) {
    nodes.sort((a, b) {
      if (a.isDirectory && !b.isDirectory) return -1;
      if (!a.isDirectory && b.isDirectory) return 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    for (final node in nodes) {
      if (node.isDirectory) {
        _sortNodes(node.children);
      }
    }
  }

  Future<NoteDocument?> loadNote(String filePath, String rootPath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return null;
    }
    final content = await file.readAsString();
    final relPath = p.relative(filePath, from: rootPath);
    return NoteDocument.parse(
      filePath: filePath,
      relativePath: relPath,
      content: content,
    );
  }

  Future<void> saveNoteAtomic(NoteDocument doc) async {
    final file = File(doc.filePath);
    final dir = file.parent;
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final tmpFile = File('${doc.filePath}.spinel_tmp_${DateTime.now().millisecondsSinceEpoch}');
    await tmpFile.writeAsString(doc.toRawContent(), flush: true);
    await tmpFile.rename(doc.filePath);
    doc.isModified = false;
  }

  Future<NoteDocument> createNote(String rootPath, String relativePath, String title) async {
    final fullPath = p.join(rootPath, relativePath);
    final file = File(fullPath);
    await file.parent.create(recursive: true);

    final initialContent = '''---
title: "$title"
date: ${DateTime.now().toIso8601String().substring(0, 10)}
tags: []
---

# $title

Start typing your notes here...
''';

    final doc = NoteDocument.parse(
      filePath: fullPath,
      relativePath: relativePath,
      content: initialContent,
    );
    await saveNoteAtomic(doc);
    return doc;
  }
}
