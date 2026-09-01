import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:app/models/note_document.dart';
import 'package:app/state/vault_provider.dart';
import 'package:app/theme/spinel_theme.dart';
import 'package:app/widgets/dual_mode_editor.dart';
import 'package:app/widgets/file_tree_sidebar.dart';
import 'package:app/widgets/frontmatter_drawer.dart';

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
  bool _showFrontmatter = true;

  @override
  void initState() {
    super.initState();
    // Default to sample vault if present, or current directory
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final samplePath = p.join(Directory.current.path, '..', 'shared', 'fixtures', 'sample_vault');
      if (Directory(samplePath).existsSync()) {
        ref.read(vaultPathProvider.notifier).setPath(samplePath);
      } else {
        ref.read(vaultPathProvider.notifier).setPath(Directory.current.path);
      }
    });
  }

  void _createNewNoteDialog() {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: SpinelTheme.darkCard,
          title: const Text('Create New Note', style: TextStyle(color: SpinelTheme.brightText)),
          content: TextField(
            controller: titleController,
            autofocus: true,
            style: const TextStyle(color: SpinelTheme.brightText),
            decoration: const InputDecoration(
              hintText: 'Note Title (e.g. My Architecture Idea)',
              hintStyle: TextStyle(color: SpinelTheme.slateText),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: SpinelTheme.borderColor)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: SpinelTheme.rubyAccent)),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: SpinelTheme.slateText)),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: SpinelTheme.rubyAccent),
              child: const Text('Create', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                final title = titleController.text.trim();
                if (title.isEmpty) return;
                Navigator.pop(ctx);

                final vaultPath = ref.read(vaultPathProvider);
                if (vaultPath == null) return;
                final filename = '${title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_')}.md';
                final service = ref.read(vaultServiceProvider);
                final doc = await service.createNote(vaultPath, '01_Daily_Notes/$filename', title);
                ref.read(selectedNoteProvider.notifier).setNote(doc);
                ref.invalidate(vaultNodesProvider);
              },
            ),
          ],
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
            const Text('💎 Spinel', style: TextStyle(fontWeight: FontWeight.bold, color: SpinelTheme.rubyAccent)),
            if (vaultPath != null) ...[
              const SizedBox(width: 8),
              Text(
                '• ${p.basename(vaultPath)}',
                style: const TextStyle(fontSize: 12, color: SpinelTheme.slateText),
              ),
            ],
            if (selectedNote != null && selectedNote.isModified) ...[
              const SizedBox(width: 6),
              const Text('● (modified)', style: TextStyle(fontSize: 11, color: SpinelTheme.rubyGlow)),
            ],
          ],
        ),
        actions: [
          // View Mode Selector
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
                label: Text('Rendered', style: TextStyle(fontSize: 11)),
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
                  return SpinelTheme.rubyAccent.withOpacity(0.3);
                }
                return SpinelTheme.darkCard;
              }),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(
              _showFrontmatter ? Icons.label : Icons.label_outline,
              color: _showFrontmatter ? SpinelTheme.rubyAccent : SpinelTheme.slateText,
              size: 20,
            ),
            tooltip: 'Toggle Frontmatter Inspector',
            onPressed: () => setState(() => _showFrontmatter = !_showFrontmatter),
          ),
          IconButton(
            icon: const Icon(Icons.save_outlined, size: 20, color: SpinelTheme.brightText),
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
          FileTreeSidebar(onNewNote: _createNewNoteDialog),
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
          if (_showFrontmatter && selectedNote != null) ...[
            const VerticalDivider(color: SpinelTheme.borderColor, width: 1),
            FrontmatterDrawer(
              document: selectedNote,
              onUpdated: () => setState(() {}),
            ),
          ],
        ],
      ),
    );
  }
}
