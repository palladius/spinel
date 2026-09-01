import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/services/vault_service.dart';
import 'package:app/state/vault_provider.dart';
import 'package:app/theme/spinel_theme.dart';

class FileTreeSidebar extends ConsumerWidget {
  final VoidCallback onNewNote;

  const FileTreeSidebar({super.key, required this.onNewNote});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nodesAsync = ref.watch(vaultNodesProvider);
    final selectedNote = ref.watch(selectedNoteProvider);

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
                Row(
                  children: const [
                    Text('💎', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 6),
                    Text(
                      'SPINEL VAULT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: SpinelTheme.rubyAccent,
                      ),
                    ),
                  ],
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
                  return const Center(
                    child: Text(
                      'No markdown notes.\nClick + to create one.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: SpinelTheme.slateText, fontSize: 12),
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  children: nodes.map((node) => _buildTreeNode(context, ref, node, selectedNote)).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: SpinelTheme.rubyAccent)),
              error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red, fontSize: 11))),
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
        leading: const Icon(Icons.folder_outlined, size: 16, color: SpinelTheme.rubyAccent),
        title: Text(
          node.name,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SpinelTheme.brightText),
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
      selectedTileColor: SpinelTheme.rubyAccent.withOpacity(0.18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      leading: const Icon(Icons.description_outlined, size: 15, color: SpinelTheme.slateText),
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
