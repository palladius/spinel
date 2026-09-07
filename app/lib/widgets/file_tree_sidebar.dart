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
      width: 220,
      color: SpinelTheme.darkSidebar,
      child: Column(
        children: [
          // Sleek Sidebar Header
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: SpinelTheme.borderColor)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: onSelectVault,
                  borderRadius: BorderRadius.circular(3),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                    child: Row(
                      children: [
                        const Text('💎', style: TextStyle(fontSize: 11)),
                        const SizedBox(width: 5),
                        Text(
                          vaultName,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: SpinelTheme.softText,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.arrow_drop_down, size: 14, color: SpinelTheme.slateText),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: onNewNote,
                  borderRadius: BorderRadius.circular(3),
                  child: const Padding(
                    padding: EdgeInsets.all(3),
                    child: Icon(Icons.add, size: 15, color: SpinelTheme.softText),
                  ),
                ),
              ],
            ),
          ),

          // High-Density File Tree
          Expanded(
            child: nodesAsync.when(
              data: (nodes) {
                if (nodes.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.folder_open, size: 20, color: SpinelTheme.slateMuted),
                          const SizedBox(height: 4),
                          const Text(
                            'Vault is empty',
                            style: TextStyle(color: SpinelTheme.softText, fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: SpinelTheme.borderColor),
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            ),
                            onPressed: onNewNote,
                            child: const Text('New Note', style: TextStyle(fontSize: 10, color: SpinelTheme.brightText)),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                  children: nodes.map((node) => _TreeNodeWidget(node: node, selectedNote: selectedNote, depth: 0)).toList(),
                );
              },
              loading: () => const Center(child: SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: SpinelTheme.rubyPrimary))),
              error: (err, _) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Error: $err', style: const TextStyle(color: Colors.redAccent, fontSize: 10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TreeNodeWidget extends ConsumerStatefulWidget {
  final VaultFileNode node;
  final dynamic selectedNote;
  final int depth;

  const _TreeNodeWidget({
    required this.node,
    required this.selectedNote,
    required this.depth,
  });

  @override
  ConsumerState<_TreeNodeWidget> createState() => _TreeNodeWidgetState();
}

class _TreeNodeWidgetState extends ConsumerState<_TreeNodeWidget> {
  bool _isExpanded = true;

  Color _getFolderColor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('daily') || lower.contains('journal') || lower.contains('01')) {
      return const Color(0xFFF59E0B); // Warm Amber Gold
    } else if (lower.contains('project') || lower.contains('02') || lower.contains('work')) {
      return const Color(0xFF38BDF8); // Vibrant Sky Blue
    } else if (lower.contains('resource') || lower.contains('03') || lower.contains('learn')) {
      return const Color(0xFF34D399); // Emerald Mint
    } else if (lower.contains('archive') || lower.contains('trash')) {
      return const Color(0xFF94A3B8); // Slate Gray
    }
    // Gemstone color palette hash
    const palette = [
      Color(0xFFC084FC), // Amethyst
      Color(0xFFFB7185), // Rose Ruby
      Color(0xFFFBBF24), // Topaz
      Color(0xFF2DD4BF), // Teal
      Color(0xFF818CF8), // Indigo
    ];
    return palette[name.hashCode.abs() % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final depth = widget.depth;
    final selectedNote = widget.selectedNote;

    if (node.isDirectory) {
      final folderColor = _getFolderColor(node.name);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(3),
            child: Container(
              height: 22,
              padding: EdgeInsets.only(left: 4.0 + (depth * 10.0), right: 4.0),
              child: Row(
                children: [
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_down : Icons.chevron_right,
                    size: 13,
                    color: SpinelTheme.slateText,
                  ),
                  const SizedBox(width: 3),
                  Icon(
                    _isExpanded ? Icons.folder_open_rounded : Icons.folder_rounded,
                    size: 13,
                    color: folderColor,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      node.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: _isExpanded ? SpinelTheme.brightText : SpinelTheme.softText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            ...node.children.map((child) => _TreeNodeWidget(node: child, selectedNote: selectedNote, depth: depth + 1)),
        ],
      );
    }

    final isSelected = selectedNote != null && selectedNote.filePath == node.path;
    final displayName = node.name.endsWith('.md') ? node.name.substring(0, node.name.length - 3) : node.name;

    return InkWell(
      borderRadius: BorderRadius.circular(3),
      onTap: () async {
        final vaultPath = ref.read(vaultPathProvider);
        if (vaultPath == null) return;
        final service = ref.read(vaultServiceProvider);
        final doc = await service.loadNote(node.path, vaultPath);
        ref.read(selectedNoteProvider.notifier).setNote(doc);
      },
      child: Container(
        height: 21,
        margin: const EdgeInsets.symmetric(vertical: 0.5),
        padding: EdgeInsets.only(left: 18.0 + (depth * 10.0), right: 6.0),
        decoration: BoxDecoration(
          color: isSelected ? SpinelTheme.rubyPrimary.withOpacity(0.28) : Colors.transparent,
          borderRadius: BorderRadius.circular(3),
          border: isSelected ? Border.all(color: SpinelTheme.rubyPrimary.withOpacity(0.5), width: 0.8) : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.article_outlined,
              size: 12,
              color: isSelected ? SpinelTheme.rubyLight : SpinelTheme.slateMuted,
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.white : SpinelTheme.softText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
