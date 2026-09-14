import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:app/models/note_document.dart';
import 'package:app/services/vault_service.dart';
import 'package:app/state/vault_provider.dart';
import 'package:app/state/sync_provider.dart';
import 'package:app/theme/spinel_theme.dart';
import 'package:app/widgets/dual_mode_editor.dart';
import 'package:app/widgets/file_tree_sidebar.dart';
import 'package:app/widgets/frontmatter_dialog.dart';
import 'package:app/widgets/sync_dialog.dart';
import 'package:app/widgets/conflict_resolution_dialog.dart';

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
          final canon = p.canonicalize(candidate);
          ref.read(vaultPathProvider.notifier).setPath(canon);
          ref.read(syncProvider.notifier).loadConfigForVault(canon);
          return;
        }
      }
      ref.read(vaultPathProvider.notifier).setPath(currentDir);
      ref.read(syncProvider.notifier).loadConfigForVault(currentDir);
    });
  }

  void _switchVaultDialog() {
    final pathController = TextEditingController(text: ref.read(vaultPathProvider) ?? '');
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: SpinelTheme.darkCard,
          title: const Text('Open / Switch Vault', style: TextStyle(color: SpinelTheme.brightText, fontSize: 14)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter directory path of your markdown vault:',
                style: TextStyle(color: SpinelTheme.slateText, fontSize: 12),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: pathController,
                style: const TextStyle(color: SpinelTheme.brightText, fontSize: 12.5),
                decoration: InputDecoration(
                  hintText: '/path/to/markdown/vault',
                  hintStyle: const TextStyle(color: SpinelTheme.slateText),
                  filled: true,
                  fillColor: SpinelTheme.darkInput,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
              child: const Text('Cancel', style: TextStyle(color: SpinelTheme.slateText, fontSize: 12)),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: SpinelTheme.rubyPrimary,
                visualDensity: VisualDensity.compact,
              ),
              child: const Text('Open Vault', style: TextStyle(color: Colors.white, fontSize: 12)),
              onPressed: () {
                final targetPath = pathController.text.trim();
                if (targetPath.isNotEmpty && Directory(targetPath).existsSync()) {
                  ref.read(vaultPathProvider.notifier).setPath(targetPath);
                  ref.read(syncProvider.notifier).loadConfigForVault(targetPath);
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
              title: const Text('Create New Note', style: TextStyle(color: SpinelTheme.brightText, fontSize: 14)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    style: const TextStyle(color: SpinelTheme.brightText, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Note Title (e.g. SRE Architecture)',
                      hintStyle: TextStyle(color: SpinelTheme.slateText, fontSize: 12),
                      isDense: true,
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: SpinelTheme.borderColor)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: SpinelTheme.rubyPrimary)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text('Save in folder:', style: TextStyle(color: SpinelTheme.slateText, fontSize: 11.5)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: selectedFolder,
                    dropdownColor: SpinelTheme.darkCard,
                    isDense: true,
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
                  child: const Text('Cancel', style: TextStyle(color: SpinelTheme.slateText, fontSize: 12)),
                  onPressed: () => Navigator.pop(ctx),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: SpinelTheme.rubyPrimary, visualDensity: VisualDensity.compact),
                  child: const Text('Create Note', style: TextStyle(color: Colors.white, fontSize: 12)),
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
    final syncState = ref.watch(syncProvider);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: const BoxDecoration(
            color: SpinelTheme.darkSidebar,
            border: Border(bottom: BorderSide(color: SpinelTheme.borderColor)),
          ),
          child: Row(
            children: [
              const Text('💎', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              const Text(
                'Spinel',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: SpinelTheme.brightText),
              ),
              if (vaultPath != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: SpinelTheme.darkCard,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: SpinelTheme.borderColor),
                  ),
                  child: Text(
                    p.basename(vaultPath),
                    style: const TextStyle(fontSize: 10.5, color: SpinelTheme.slateText),
                  ),
                ),
              ],
              if (selectedNote != null && selectedNote.isModified) ...[
                const SizedBox(width: 6),
                const Text('● unsaved', style: TextStyle(fontSize: 10.5, color: Colors.amberAccent)),
              ],
              const Spacer(),

              // View Mode Selector
              SegmentedButton<EditorViewMode>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(
                    value: EditorViewMode.rawMarkdown,
                    label: Text('Raw', style: TextStyle(fontSize: 11)),
                  ),
                  ButtonSegment(
                    value: EditorViewMode.splitView,
                    label: Text('Split', style: TextStyle(fontSize: 11)),
                  ),
                  ButtonSegment(
                    value: EditorViewMode.renderedWysiwyg,
                    label: Text('Live', style: TextStyle(fontSize: 11)),
                  ),
                ],
                selected: {editorMode},
                onSelectionChanged: (modes) {
                  ref.read(editorModeProvider.notifier).setMode(modes.first);
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 8)),
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return SpinelTheme.rubyPrimary.withOpacity(0.35);
                    }
                    return Colors.transparent;
                  }),
                ),
              ),
              const SizedBox(width: 8),

              // Metadata Popup Button
              if (selectedNote != null)
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    side: const BorderSide(color: SpinelTheme.borderColor),
                    backgroundColor: SpinelTheme.darkCard,
                  ),
                  icon: const Icon(Icons.tune, size: 13, color: SpinelTheme.softText),
                  label: Text(
                    'Properties (${selectedNote.frontmatter.length})',
                    style: const TextStyle(fontSize: 11, color: SpinelTheme.brightText),
                  ),
                  onPressed: () {
                    FrontmatterDialog.show(context, selectedNote, () {
                      setState(() {});
                    });
                  },
                ),

              const SizedBox(width: 6),

              // Cloud Sync Action Button
              _buildSyncButton(context, ref, syncState, vaultPath),

              const SizedBox(width: 6),

              // Save Button
              IconButton(
                icon: const Icon(Icons.save_outlined, size: 16, color: SpinelTheme.softText),
                tooltip: 'Save Note (Cmd+S)',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
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
            ],
          ),
        ),
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
                      style: TextStyle(color: SpinelTheme.slateText, fontSize: 12.5),
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

  Widget _buildSyncButton(BuildContext context, WidgetRef ref, SyncState syncState, String? vaultPath) {
    Widget iconWidget;
    String tooltip;

    switch (syncState.status) {
      case SyncStatus.syncing:
        iconWidget = const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.lightBlueAccent),
        );
        tooltip = 'Syncing with cloud...';
        break;
      case SyncStatus.conflict:
        iconWidget = Stack(
          alignment: Alignment.topRight,
          children: [
            const Icon(Icons.cloud_sync, size: 16, color: Colors.amberAccent),
            Container(
              padding: const EdgeInsets.all(1.5),
              decoration: const BoxDecoration(color: Colors.amberAccent, shape: BoxShape.circle),
              child: Text(
                '${syncState.conflicts.length}',
                style: const TextStyle(fontSize: 8, color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
        tooltip = 'Sync Conflict Detected - Click to Resolve';
        break;
      case SyncStatus.synced:
        iconWidget = const Icon(Icons.cloud_done, size: 16, color: Colors.greenAccent);
        tooltip = 'Synced: ${syncState.lastSyncedAt ?? "Recently"}';
        break;
      case SyncStatus.error:
        iconWidget = const Icon(Icons.cloud_off, size: 16, color: Colors.redAccent);
        tooltip = 'Sync Error: ${syncState.errorMessage ?? "Failed"}';
        break;
      case SyncStatus.idle:
        iconWidget = const Icon(Icons.cloud_outlined, size: 16, color: SpinelTheme.softText);
        tooltip = 'Cloud Sync Settings';
        break;
    }

    return IconButton(
      icon: iconWidget,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      onPressed: () {
        if (syncState.status == SyncStatus.conflict && syncState.conflicts.isNotEmpty) {
          ConflictResolutionDialog.show(context, syncState.conflicts.first);
        } else {
          SyncDialog.show(context);
        }
      },
    );
  }
}
