import 'dart:convert';
import 'package:yaml/yaml.dart';

class NoteDocument {
  final String filePath;
  final String relativePath;
  Map<String, dynamic> frontmatter;
  String body;
  bool isModified;

  NoteDocument({
    required this.filePath,
    required this.relativePath,
    required this.frontmatter,
    required this.body,
    this.isModified = false,
  });

  String get title {
    if (frontmatter.containsKey('title') && frontmatter['title'] != null) {
      return frontmatter['title'].toString();
    }
    final fileName = relativePath.split('/').last;
    if (fileName.endsWith('.md')) {
      return fileName.substring(0, fileName.length - 3);
    }
    return fileName;
  }

  static NoteDocument parse({
    required String filePath,
    required String relativePath,
    required String content,
  }) {
    final trimmed = content.trimLeft();
    if (!trimmed.startsWith('---')) {
      return NoteDocument(
        filePath: filePath,
        relativePath: relativePath,
        frontmatter: {},
        body: content,
      );
    }

    final lines = LineSplitter.split(content).toList();
    var delimiterCount = 0;
    final yamlLines = <String>[];
    final bodyLines = <String>[];
    var inFrontmatter = false;

    for (final line in lines) {
      if (line.trim() == '---') {
        delimiterCount++;
        if (delimiterCount == 1) {
          inFrontmatter = true;
          continue;
        } else if (delimiterCount == 2) {
          inFrontmatter = false;
          continue;
        }
      }

      if (inFrontmatter) {
        yamlLines.add(line);
      } else {
        bodyLines.add(line);
      }
    }

    final parsedMap = <String, dynamic>{};
    if (yamlLines.isNotEmpty) {
      try {
        final yamlStr = yamlLines.join('\n');
        final yamlDoc = loadYaml(yamlStr);
        if (yamlDoc is Map) {
          for (final entry in yamlDoc.entries) {
            parsedMap[entry.key.toString()] = entry.value;
          }
        }
      } catch (_) {
        // Fallback gracefully on YAML parse error
      }
    }

    return NoteDocument(
      filePath: filePath,
      relativePath: relativePath,
      frontmatter: parsedMap,
      body: bodyLines.join('\n'),
    );
  }

  String toRawContent() {
    if (frontmatter.isEmpty) {
      return body;
    }
    final buffer = StringBuffer();
    buffer.writeln('---');
    for (final entry in frontmatter.entries) {
      if (entry.value is List) {
        buffer.writeln('${entry.key}:');
        for (final item in entry.value as List) {
          buffer.writeln('  - "$item"');
        }
      } else {
        buffer.writeln('${entry.key}: "${entry.value}"');
      }
    }
    buffer.writeln('---');
    buffer.write(body);
    return buffer.toString();
  }
}
