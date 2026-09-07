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
      width: 230,
      color: SpinelTheme.darkSidebar,
      child: Column(
        children: [
          // Sidebar Header
          Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: SpinelTheme.borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: onSelectVault,
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    child: Row(
                      children: [
                        const Text('💎', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 6),
                        Text(
                          vaultName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: SpinelTheme.softText,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.keyboard_arrow_down, size: 14, color: SpinelTheme.slateText),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 16, color: SpinelTheme.softText),
                  tooltip: 'New Note',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  onPressed: onNewNote,
                ),
              ],
            ),
          ),

          // File Tree
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
                          const Icon(Icons.folder_open, size: 24, color: SpinelTheme.slateMuted),
                          const SizedBox(height: 6),
                          const Text(
                            'Vault is empty',
                            style: TextStyle(color: SpinelTheme.softText, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: SpinelTheme.borderColor),
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            ),
                            onPressed: onNewNote,
                            child: const Text('New Note', style: TextStyle(fontSize: 11, color: SpinelTheme.brightText)),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                  children: nodes.map((node) => _buildTreeNode(context, ref, node, selectedNote, 0)).toList(),
                );
              },
              loading: () => const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: SpinelTheme.rubyPrimary))),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeNode(BuildContext context, WidgetRef ref, VaultFileNode node, dynamic selectedNote, int depth) {
    if (node.isDirectory) {
      return Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          dense: true,
          initiallyExpanded: true,
          shape: const Border(),
          collapsedShape: const Border(),
          tilePadding: EdgeInsets.only(left: 6.0 + (depth * 10.0), right: 6.0),
          minTileHeight: 26,
          leading: const Icon(Icons.folder_outlined, size: 14, color: SpinelTheme.slateText),
          title: Text(
            node.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: SpinelTheme.softText,
            ),
          ),
          childrenPadding: EdgeInsets.zero,
          children: node.children.map((child) => _buildTreeNode(context, ref, child, selectedNote, depth + 1)).toList(),
        ),
      );
    }

    final isSelected = selectedNote != null && selectedNote.filePath == node.path;
    final displayName = node.name.endsWith('.md') ? node.name.substring(0, node.name.length - 3) : node.name;

    return Container(
      height: 26,
      margin: const EdgeInsets.symmetric(vertical: 1),
      padding: EdgeInsets.only(left: 10.0 + (depth * 10.0), right: 6.0),
      decoration: BoxDecoration(
        color: isSelected ? SpinelTheme.rubyPrimary.withOpacity(0.25) : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: isSelected ? Border.all(color: SpinelTheme.rubyPrimary.withOpacity(0.4), width: 1) : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () async {
          final vaultPath = ref.read(vaultPathProvider);
          if (vaultPath == null) return;
          final service = ref.read(vaultServiceProvider);
          final doc = await service.loadNote(node.path, vaultPath);
          ref.read(selectedNoteProvider.notifier).setNote(doc);
        },
        child: Row(
          children: [
            Icon(
              Icons.description_outlined,
              size: 13,
              color: isSelected ? SpinelTheme.brightText : SpinelTheme.slateMuted,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? SpinelTheme.brightText : SpinelTheme.slateText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
