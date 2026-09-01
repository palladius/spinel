import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:app/services/vault_service.dart';
import 'package:app/state/vault_provider.dart';
import 'package:app/theme/spinel_theme.dart';

class FileTreeSidebar extends ConsumerWidget {
  final VoidCallback onNewNote;
  final VoidCallback onSelectVault;

  const FileTreeSidebar({
    super.key,
    required this.onNewNote,
    required this.onSelectVault,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nodesAsync = ref.watch(vaultNodesProvider);
    final selectedNote = ref.watch(selectedNoteProvider);
    final vaultPath = ref.watch(vaultPathProvider);

    final vaultName = vaultPath != null ? p.basename(vaultPath) : 'Select Vault';

    return Container(
      width: 250,
      color: SpinelTheme.darkSidebar,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: SpinelTheme.borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: onSelectVault,
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    children: [
                      const Text('💎', style: TextStyle(fontSize: 15)),
                      const SizedBox(width: 6),
                      Text(
                        vaultName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                          color: SpinelTheme.rubyBright,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_drop_down, size: 16, color: SpinelTheme.slateText),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.note_add_outlined, size: 18, color: SpinelTheme.brightText),
                  tooltip: 'New Note',
                  onPressed: onNewNote,
                ),
              ],
            ),
          ),
          Expanded(
            child: nodesAsync.when(
              data: (nodes) {
                if (nodes.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.folder_open, size: 32, color: SpinelTheme.slateText),
                          const SizedBox(height: 8),
                          const Text(
                            'Vault is empty',
                            style: TextStyle(color: SpinelTheme.brightText, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Create a note or choose another folder.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: SpinelTheme.slateText, fontSize: 11),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SpinelTheme.rubyPrimary,
                              visualDensity: VisualDensity.compact,
                            ),
                            icon: const Icon(Icons.add, size: 14, color: Colors.white),
                            label: const Text('New Note', style: TextStyle(fontSize: 11, color: Colors.white)),
                            onPressed: onNewNote,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  children: nodes.map((node) => _buildTreeNode(context, ref, node, selectedNote)).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: SpinelTheme.rubyPrimary)),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline, size: 32, color: SpinelTheme.rubyBright),
                    const SizedBox(height: 8),
                    const Text(
                      'Access Restricted',
                      style: TextStyle(color: SpinelTheme.brightText, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$err',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: SpinelTheme.slateText, fontSize: 11),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SpinelTheme.rubyPrimary,
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: onSelectVault,
                      child: const Text('Choose Folder', style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeNode(BuildContext context, WidgetRef ref, VaultFileNode node, dynamic selectedNote) {
    if (node.isDirectory) {
      return ExpansionTile(
        dense: true,
        initiallyExpanded: true,
        leading: const Icon(Icons.folder_outlined, size: 16, color: SpinelTheme.rubyBright),
        title: Text(
          node.name,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: SpinelTheme.brightText),
        ),
        childrenPadding: const EdgeInsets.only(left: 14),
        children: node.children.map((child) => _buildTreeNode(context, ref, child, selectedNote)).toList(),
      );
    }

    final isSelected = selectedNote != null && selectedNote.filePath == node.path;

    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      selected: isSelected,
      selectedTileColor: SpinelTheme.rubyPrimary.withOpacity(0.22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      leading: Icon(
        Icons.description_outlined,
        size: 15,
        color: isSelected ? SpinelTheme.rubyBright : SpinelTheme.slateText,
      ),
      title: Text(
        node.name.endsWith('.md') ? node.name.substring(0, node.name.length - 3) : node.name,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? SpinelTheme.brightText : SpinelTheme.slateText,
        ),
      ),
      onTap: () async {
        final vaultPath = ref.read(vaultPathProvider);
        if (vaultPath == null) return;
        final service = ref.read(vaultServiceProvider);
        final doc = await service.loadNote(node.path, vaultPath);
        ref.read(selectedNoteProvider.notifier).setNote(doc);
      },
    );
  }
}
