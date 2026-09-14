import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/services/sync_service.dart';
import 'package:app/state/sync_provider.dart';
import 'package:app/state/vault_provider.dart';
import 'package:app/theme/spinel_theme.dart';

class ConflictResolutionDialog extends ConsumerWidget {
  final SyncConflict conflict;

  const ConflictResolutionDialog({
    super.key,
    required this.conflict,
  });

  static void show(BuildContext context, SyncConflict conflict) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ConflictResolutionDialog(conflict: conflict),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaultPath = ref.watch(vaultPathProvider);

    return Dialog(
      backgroundColor: SpinelTheme.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 850,
        height: 600,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.amberAccent, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sync Conflict Detected',
                        style: TextStyle(color: SpinelTheme.brightText, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'File: ${conflict.relativePath} (Server Version: ${conflict.serverVersion})',
                        style: const TextStyle(color: SpinelTheme.slateText, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: SpinelTheme.slateText),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(color: SpinelTheme.borderColor, height: 24),

            // Side-by-Side Comparison
            Expanded(
              child: Row(
                children: [
                  // Local Version Pane
                  Expanded(
                    child: _buildPane(
                      title: 'Local Version (On Disk)',
                      badgeColor: SpinelTheme.rubyPrimary,
                      content: conflict.localContent,
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Remote Server Pane
                  Expanded(
                    child: _buildPane(
                      title: 'Server Version (Remote Cloud)',
                      badgeColor: Colors.lightBlueAccent,
                      content: conflict.remoteContent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Resolution Action Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: SpinelTheme.rubyPrimary),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.description, size: 14, color: SpinelTheme.rubyLight),
                  label: const Text('Keep Local', style: TextStyle(color: SpinelTheme.brightText, fontSize: 12)),
                  onPressed: () async {
                    await ref.read(syncProvider.notifier).resolveConflict(
                          vaultPath: vaultPath,
                          conflict: conflict,
                          strategy: ConflictResolutionStrategy.keepLocal,
                        );
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.lightBlueAccent),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.cloud_download, size: 14, color: Colors.lightBlueAccent),
                  label: const Text('Accept Remote', style: TextStyle(color: SpinelTheme.brightText, fontSize: 12)),
                  onPressed: () async {
                    await ref.read(syncProvider.notifier).resolveConflict(
                          vaultPath: vaultPath,
                          conflict: conflict,
                          strategy: ConflictResolutionStrategy.acceptRemote,
                        );
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SpinelTheme.rubyPrimary,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.call_split, size: 14, color: Colors.white),
                  label: const Text('Keep Both (Fork _conflict.md)', style: TextStyle(color: Colors.white, fontSize: 12)),
                  onPressed: () async {
                    await ref.read(syncProvider.notifier).resolveConflict(
                          vaultPath: vaultPath,
                          conflict: conflict,
                          strategy: ConflictResolutionStrategy.keepBoth,
                        );
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPane({
    required String title,
    required Color badgeColor,
    required String content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: SpinelTheme.darkCanvas,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: SpinelTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: SpinelTheme.darkSidebar,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
              border: const Border(bottom: BorderSide(color: SpinelTheme.borderColor)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: SpinelTheme.brightText, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: SelectableText(
                content,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11.5,
                  height: 1.4,
                  color: SpinelTheme.brightText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
