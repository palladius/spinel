import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:app/services/vault_service.dart';
import 'package:app/state/vault_provider.dart';
import 'package:app/theme/spinel_theme.dart';

class NewNoteDialog extends ConsumerStatefulWidget {
  const NewNoteDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const NewNoteDialog(),
    );
  }

  @override
  ConsumerState<NewNoteDialog> createState() => _NewNoteDialogState();
}

class _NewNoteDialogState extends ConsumerState<NewNoteDialog> {
  late final TextEditingController _titleController;
  late final List<String> _folderList;
  late String _selectedFolder;

  @override
  void initState() {
    super.initState();
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    _titleController = TextEditingController(text: todayStr);
    _titleController.selection = TextSelection(baseOffset: 0, extentOffset: todayStr.length);

    final selectedNote = ref.read(selectedNoteProvider);
    final vaultPath = ref.read(vaultPathProvider);
    final vaultNodes = ref.read(vaultNodesProvider).value ?? [];

    _folderList = <String>['/ (Root)'];
    void extractDirs(List<VaultFileNode> nodes) {
      for (final n in nodes) {
        if (n.isDirectory) {
          _folderList.add(n.relativePath);
          extractDirs(n.children);
        }
      }
    }
    extractDirs(vaultNodes);

    // If vaultNodes has not loaded yet, discover directories directly from vaultPath on disk
    if (_folderList.length == 1 && vaultPath != null && Directory(vaultPath).existsSync()) {
      try {
        final rootDir = Directory(vaultPath);
        for (final entity in rootDir.listSync(recursive: true, followLinks: false)) {
          if (entity is Directory) {
            final rel = p.relative(entity.path, from: vaultPath);
            final base = p.basename(entity.path);
            if (!base.startsWith('.') && base != 'node_modules' && base != 'build') {
              if (!_folderList.contains(rel)) {
                _folderList.add(rel);
              }
            }
          }
        }
      } catch (_) {}
    }

    _selectedFolder = _folderList.first;
    if (selectedNote != null) {
      final parentDir = p.dirname(selectedNote.relativePath);
      if (parentDir != '.' && _folderList.contains(parentDir)) {
        _selectedFolder = parentDir;
      }
    } else if (_folderList.contains('01_Daily_Notes')) {
      _selectedFolder = '01_Daily_Notes';
    } else if (_folderList.contains('notes')) {
      _selectedFolder = 'notes';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final rawText = _titleController.text.trim();
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final title = rawText.isNotEmpty ? rawText : todayStr;

    Navigator.pop(context);

    final vaultPath = ref.read(vaultPathProvider);
    if (vaultPath == null) return;

    final filename = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(title)
        ? '$title.md'
        : '${title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_-]+'), '_')}.md';
    final targetRelPath = _selectedFolder == '/ (Root)'
        ? filename
        : p.join(_selectedFolder, filename);

    final service = ref.read(vaultServiceProvider);
    final doc = await service.createNote(vaultPath, targetRelPath, title);
    ref.read(selectedNoteProvider.notifier).setNote(doc);
    ref.invalidate(vaultNodesProvider);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: SpinelTheme.darkCard,
      title: const Text('Create New Note', style: TextStyle(color: SpinelTheme.brightText, fontSize: 14)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            autofocus: true,
            style: const TextStyle(color: SpinelTheme.brightText, fontSize: 13),
            decoration: const InputDecoration(
              hintText: 'Note Title (e.g. SRE Architecture)',
              hintStyle: TextStyle(color: SpinelTheme.slateText, fontSize: 12),
              isDense: true,
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: SpinelTheme.borderColor)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: SpinelTheme.rubyPrimary)),
            ),
            onSubmitted: (_) => _handleCreate(),
          ),
          const SizedBox(height: 14),
          const Text('Save in folder:', style: TextStyle(color: SpinelTheme.slateText, fontSize: 11.5)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _selectedFolder,
            dropdownColor: SpinelTheme.darkCard,
            isDense: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: SpinelTheme.darkInput,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: SpinelTheme.borderColor)),
            ),
            style: const TextStyle(color: SpinelTheme.brightText, fontSize: 12),
            items: _folderList.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedFolder = val;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('Cancel', style: TextStyle(color: SpinelTheme.slateText, fontSize: 12)),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: SpinelTheme.rubyPrimary, visualDensity: VisualDensity.compact),
          onPressed: _handleCreate,
          child: const Text('Create Note', style: TextStyle(color: Colors.white, fontSize: 12)),
        ),
      ],
    );
  }
}
