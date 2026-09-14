import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/state/sync_provider.dart';
import 'package:app/state/vault_provider.dart';
import 'package:app/theme/spinel_theme.dart';
import 'package:app/widgets/conflict_resolution_dialog.dart';

class SyncDialog extends ConsumerStatefulWidget {
  const SyncDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const SyncDialog(),
    );
  }

  @override
  ConsumerState<SyncDialog> createState() => _SyncDialogState();
}

class _SyncDialogState extends ConsumerState<SyncDialog> {
  late TextEditingController _urlController;
  late TextEditingController _tokenController;
  late TextEditingController _passphraseController;
  bool _obscureToken = true;
  bool _obscurePassphrase = true;

  @override
  void initState() {
    super.initState();
    final config = ref.read(syncProvider).config;
    _urlController = TextEditingController(text: config.remoteUrl);
    _tokenController = TextEditingController(text: config.apiToken);
    _passphraseController = TextEditingController(text: config.passphrase);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _tokenController.dispose();
    _passphraseController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final vaultPath = ref.read(vaultPathProvider);
    final current = ref.read(syncProvider).config;
    final updated = current.copyWith(
      remoteUrl: _urlController.text.trim(),
      apiToken: _tokenController.text.trim(),
      passphrase: _passphraseController.text.trim(),
    );
    ref.read(syncProvider.notifier).updateConfig(vaultPath, updated);
  }

  @override
  Widget build(BuildContext context) {
    final syncState = ref.watch(syncProvider);
    final vaultPath = ref.watch(vaultPathProvider);

    return AlertDialog(
      backgroundColor: SpinelTheme.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Row(
        children: [
          const Icon(Icons.cloud_sync, color: SpinelTheme.rubyBright, size: 20),
          const SizedBox(width: 8),
          const Text('Cloud Sync Settings', style: TextStyle(color: SpinelTheme.brightText, fontSize: 15)),
          const Spacer(),
          _buildStatusBadge(syncState),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Server URL Field
              const Text('Remote Sync Server URL:', style: TextStyle(color: SpinelTheme.slateText, fontSize: 11.5)),
              const SizedBox(height: 6),
              TextField(
                controller: _urlController,
                style: const TextStyle(color: SpinelTheme.brightText, fontSize: 12.5),
                decoration: _inputDecoration('https://spinel-api.run.app or http://localhost:8080'),
                onChanged: (_) => _saveSettings(),
              ),
              const SizedBox(height: 14),

              // API Token Field
              const Text('Vault API Token:', style: TextStyle(color: SpinelTheme.slateText, fontSize: 11.5)),
              const SizedBox(height: 6),
              TextField(
                controller: _tokenController,
                obscureText: _obscureToken,
                style: const TextStyle(color: SpinelTheme.brightText, fontSize: 12.5),
                decoration: _inputDecoration('Bearer token for vault authorization').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscureToken ? Icons.visibility_off : Icons.visibility, size: 16, color: SpinelTheme.slateText),
                    onPressed: () => setState(() => _obscureToken = !_obscureToken),
                  ),
                ),
                onChanged: (_) => _saveSettings(),
              ),
              const SizedBox(height: 14),

              // Passphrase Field
              const Text('Zero-Knowledge Encryption Passphrase:', style: TextStyle(color: SpinelTheme.slateText, fontSize: 11.5)),
              const SizedBox(height: 6),
              TextField(
                controller: _passphraseController,
                obscureText: _obscurePassphrase,
                style: const TextStyle(color: SpinelTheme.brightText, fontSize: 12.5),
                decoration: _inputDecoration('Secret passphrase for AES-256 vault encryption').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassphrase ? Icons.visibility_off : Icons.visibility, size: 16, color: SpinelTheme.slateText),
                    onPressed: () => setState(() => _obscurePassphrase = !_obscurePassphrase),
                  ),
                ),
                onChanged: (_) => _saveSettings(),
              ),
              const SizedBox(height: 16),

              // Status Summary & Conflict Alert
              if (syncState.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, size: 16, color: Colors.redAccent),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          syncState.errorMessage!,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 11.5),
                        ),
                      ),
                    ],
                  ),
                ),

              if (syncState.conflicts.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.amberAccent.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.amberAccent),
                          const SizedBox(width: 6),
                          Text(
                            '${syncState.conflicts.length} Pending Conflict(s)',
                            style: const TextStyle(color: Colors.amberAccent, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...syncState.conflicts.map(
                        (conflict) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  conflict.relativePath,
                                  style: const TextStyle(color: SpinelTheme.brightText, fontSize: 11.5, fontFamily: 'monospace'),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SpinelTheme.rubyPrimary,
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                ),
                                child: const Text('Resolve', style: TextStyle(fontSize: 10.5, color: Colors.white)),
                                onPressed: () {
                                  Navigator.pop(context);
                                  ConflictResolutionDialog.show(context, conflict);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (syncState.lastSyncedAt != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Last Synced: ${syncState.lastSyncedAt} (${syncState.appliedCount} notes synced)',
                  style: const TextStyle(color: SpinelTheme.slateText, fontSize: 11),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Close', style: TextStyle(color: SpinelTheme.slateText, fontSize: 12)),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: SpinelTheme.rubyPrimary,
            visualDensity: VisualDensity.compact,
          ),
          icon: syncState.status == SyncStatus.syncing
              ? const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.sync, size: 14, color: Colors.white),
          label: Text(
            syncState.status == SyncStatus.syncing ? 'Syncing...' : 'Sync Now',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          onPressed: syncState.status == SyncStatus.syncing
              ? null
              : () async {
                  _saveSettings();
                  await ref.read(syncProvider.notifier).triggerSync(vaultPath);
                },
        ),
      ],
    );
  }

  Widget _buildStatusBadge(SyncState state) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (state.status) {
      case SyncStatus.idle:
        bg = SpinelTheme.darkCanvas;
        fg = SpinelTheme.slateText;
        label = 'Idle';
        icon = Icons.cloud_outlined;
        break;
      case SyncStatus.syncing:
        bg = Colors.blue.withOpacity(0.2);
        fg = Colors.lightBlueAccent;
        label = 'Syncing';
        icon = Icons.sync;
        break;
      case SyncStatus.synced:
        bg = Colors.green.withOpacity(0.2);
        fg = Colors.greenAccent;
        label = 'Synced';
        icon = Icons.cloud_done;
        break;
      case SyncStatus.error:
        bg = Colors.red.withOpacity(0.2);
        fg = Colors.redAccent;
        label = 'Error';
        icon = Icons.error_outline;
        break;
      case SyncStatus.conflict:
        bg = Colors.amber.withOpacity(0.2);
        fg = Colors.amberAccent;
        label = 'Conflict';
        icon = Icons.warning_amber_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: fg.withOpacity(0.4))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: fg, fontSize: 10.5, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: SpinelTheme.slateMuted, fontSize: 11),
      filled: true,
      fillColor: SpinelTheme.darkInput,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: SpinelTheme.borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: SpinelTheme.rubyPrimary)),
    );
  }
}
