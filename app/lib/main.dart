import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:app/models/note_document.dart';
import 'package:app/services/vault_service.dart';
import 'package:app/state/vault_provider.dart';
import 'package:app/theme/spinel_theme.dart';
import 'package:app/widgets/dual_mode_editor.dart';
import 'package:app/widgets/file_tree_sidebar.dart';
import 'package:app/widgets/frontmatter_dialog.dart';

void main() {
  runApp(const ProviderScope(child: SpinelApp()));
}

class SpinelApp extends StatelessWidget {
  const SpinelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spinel',
      debugShowCheckedModeBanner: false,
      theme: SpinelTheme.darkTheme,
      home: const SpinelHomeScreen(),
    );
  }
}

class SpinelHomeScreen extends ConsumerStatefulWidget {
  const SpinelHomeScreen({super.key});

  @override
  ConsumerState<SpinelHomeScreen> createState() => _SpinelHomeScreenState();
}

class _SpinelHomeScreenState extends ConsumerState<SpinelHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentDir = Directory.current.path;
      final candidates = [
        p.join(currentDir, 'shared', 'fixtures', 'sample_vault'),
        p.join(currentDir, '..', 'shared', 'fixtures', 'sample_vault'),
        '/Users/ricc/git/spinel/shared/fixtures/sample_vault',
        '/Users/ricc/Documents/antigravity/zealous-hypatia/shared/fixtures/sample_vault',
      ];

      for (final candidate in candidates) {
        if (Directory(candidate).existsSync()) {
          ref.read(vaultPathProvider.notifier).setPath(p.canonicalize(candidate));
          return;
        }
      }
      ref.read(vaultPathProvider.notifier).setPath(currentDir);
    });
  }

  void _switchVaultDialog() {
    final pathController = TextEditingController(text: ref.read(vaultPathProvider) ?? '');
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: SpinelTheme.darkCard,
          title: const Text('Open / Switch Vault', style: TextStyle(color: SpinelTheme.brightText)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the directory path of your markdown vault:',
                style: TextStyle(color: SpinelTheme.slateText, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pathController,
                style: const TextStyle(color: SpinelTheme.brightText, fontSize: 13),
                decoration: InputDecoration(
                  hintText: '/path/to/markdown/vault',
                  hintStyle: const TextStyle(color: SpinelTheme.slateText),
                  filled: true,
                  fillColor: SpinelTheme.darkInput,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: SpinelTheme.borderColor),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: SpinelTheme.slateText)),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: SpinelTheme.rubyPrimary),
              child: const Text('Open Vault', style: TextStyle(color: Colors.white)),
              onPressed: () {
                final targetPath = pathController.text.trim();
                if (targetPath.isNotEmpty && Directory(targetPath).existsSync()) {
                  ref.read(vaultPathProvider.notifier).setPath(targetPath);
                  ref.read(selectedNoteProvider.notifier).setNote(null);
                  ref.invalidate(vaultNodesProvider);
                }
                Navigator.pop(ctx);
              },
            ),
          ],
        );
      },
    );
  }

  void _createNewNoteDialog() {
    final titleController = TextEditingController();
    final selectedNote = ref.read(selectedNoteProvider);
    final vaultNodes = ref.read(vaultNodesProvider).value ?? [];

    // Collect available directories in vault
    final folderList = <String>['/ (Root)'];
    void extractDirs(List<VaultFileNode> nodes) {
      for (final n in nodes) {
        if (n.isDirectory) {
          folderList.add(n.relativePath);
          extractDirs(n.children);
        }
      }
    }
    extractDirs(vaultNodes);

    // Default folder: current note's parent dir if any, otherwise first available or root
    String selectedFolder = folderList.first;
    if (selectedNote != null) {
      final parentDir = p.dirname(selectedNote.relativePath);
      if (parentDir != '.' && folderList.contains(parentDir)) {
        selectedFolder = parentDir;
      }
    } else if (folderList.contains('01_Daily_Notes')) {
      selectedFolder = '01_Daily_Notes';
    } else if (folderList.contains('notes')) {
      selectedFolder = 'notes';
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: SpinelTheme.darkCard,
              title: const Text('Create New Note', style: TextStyle(color: SpinelTheme.brightText)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    style: const TextStyle(color: SpinelTheme.brightText),
                    decoration: const InputDecoration(
                      hintText: 'Note Title (e.g. SRE Architecture)',
                      hintStyle: TextStyle(color: SpinelTheme.slateText),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: SpinelTheme.borderColor)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: SpinelTheme.rubyPrimary)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Save in folder:', style: TextStyle(color: SpinelTheme.slateText, fontSize: 12)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedFolder,
                    dropdownColor: SpinelTheme.darkCard,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: SpinelTheme.darkInput,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: SpinelTheme.borderColor)),
                    ),
                    style: const TextStyle(color: SpinelTheme.brightText, fontSize: 12),
                    items: folderList.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() {
                          selectedFolder = val;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel', style: TextStyle(color: SpinelTheme.slateText)),
                  onPressed: () => Navigator.pop(ctx),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: SpinelTheme.rubyPrimary),
                  child: const Text('Create Note', style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;
                    Navigator.pop(ctx);

                    final vaultPath = ref.read(vaultPathProvider);
                    if (vaultPath == null) return;
                    final filename = '${title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}.md';
                    
                    final targetRelPath = selectedFolder == '/ (Root)' 
                        ? filename 
                        : p.join(selectedFolder, filename);

                    final service = ref.read(vaultServiceProvider);
                    final doc = await service.createNote(vaultPath, targetRelPath, title);
                    ref.read(selectedNoteProvider.notifier).setNote(doc);
                    ref.invalidate(vaultNodesProvider);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedNote = ref.watch(selectedNoteProvider);
    final editorMode = ref.watch(editorModeProvider);
    final vaultPath = ref.watch(vaultPathProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('💎 Spinel', style: TextStyle(fontWeight: FontWeight.bold, color: SpinelTheme.rubyBright)),
            if (vaultPath != null) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: SpinelTheme.darkCard,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: SpinelTheme.borderColor),
                ),
                child: Text(
                  p.basename(vaultPath),
                  style: const TextStyle(fontSize: 11, color: SpinelTheme.slateText),
                ),
              ),
            ],
            if (selectedNote != null && selectedNote.isModified) ...[
              const SizedBox(width: 8),
              const Text('● unsaved', style: TextStyle(fontSize: 11, color: Colors.orangeAccent)),
            ],
          ],
        ),
        actions: [
          // Mode Toggle
          SegmentedButton<EditorViewMode>(
            segments: const [
              ButtonSegment(
                value: EditorViewMode.rawMarkdown,
                icon: Icon(Icons.code, size: 14),
                label: Text('Raw', style: TextStyle(fontSize: 11)),
              ),
              ButtonSegment(
                value: EditorViewMode.splitView,
                icon: Icon(Icons.vertical_split, size: 14),
                label: Text('Split', style: TextStyle(fontSize: 11)),
              ),
              ButtonSegment(
                value: EditorViewMode.renderedWysiwyg,
                icon: Icon(Icons.auto_stories, size: 14),
                label: Text('Live Preview', style: TextStyle(fontSize: 11)),
              ),
            ],
            selected: {editorMode},
            onSelectionChanged: (modes) {
              ref.read(editorModeProvider.notifier).setMode(modes.first);
            },
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return SpinelTheme.rubyPrimary.withOpacity(0.35);
                }
                return SpinelTheme.darkCard;
              }),
            ),
          ),
          const SizedBox(width: 8),

          // Frontmatter Popup Button
          if (selectedNote != null)
            TextButton.icon(
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: SpinelTheme.brightText,
                backgroundColor: SpinelTheme.darkCard,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                  side: const BorderSide(color: SpinelTheme.borderColor),
                ),
              ),
              icon: const Icon(Icons.tune, size: 15, color: SpinelTheme.rubyBright),
              label: Text(
                'Metadata (${selectedNote.frontmatter.length})',
                style: const TextStyle(fontSize: 11),
              ),
              onPressed: () {
                FrontmatterDialog.show(context, selectedNote, () {
                  setState(() {});
                });
              },
            ),

          const SizedBox(width: 8),

          // Save Button
          IconButton(
            icon: const Icon(Icons.save_outlined, size: 19, color: SpinelTheme.brightText),
            tooltip: 'Save Note (Cmd+S)',
            onPressed: selectedNote == null
                ? null
                : () async {
                    final service = ref.read(vaultServiceProvider);
                    await service.saveNoteAtomic(selectedNote);
                    ref.read(selectedNoteProvider.notifier).setNote(NoteDocument(
                      filePath: selectedNote.filePath,
                      relativePath: selectedNote.relativePath,
                      frontmatter: selectedNote.frontmatter,
                      body: selectedNote.body,
                      isModified: false,
                    ));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Note saved to disk.'),
                        duration: Duration(seconds: 1),
                        backgroundColor: SpinelTheme.darkCard,
                      ),
                    );
                  },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          FileTreeSidebar(
            onNewNote: _createNewNoteDialog,
            onSelectVault: _switchVaultDialog,
          ),
          const VerticalDivider(color: SpinelTheme.borderColor, width: 1),
          Expanded(
            child: selectedNote == null
                ? const Center(
                    child: Text(
                      'Select a note from the sidebar\nor create a new one to begin editing.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: SpinelTheme.slateText, fontSize: 13),
                    ),
                  )
                : DualModeEditor(
                    document: selectedNote,
                    mode: editorMode,
                    onBodyChanged: (newBody) {
                      selectedNote.body = newBody;
                      selectedNote.isModified = true;
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
