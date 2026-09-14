import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:app/services/sync_service.dart';
import 'package:app/state/vault_provider.dart';

enum SyncStatus {
  idle,
  syncing,
  synced,
  error,
  conflict,
}

class SyncConfig {
  final String remoteUrl;
  final String apiToken;
  final String passphrase;
  final bool autoSync;

  const SyncConfig({
    this.remoteUrl = 'http://localhost:8080',
    this.apiToken = '',
    this.passphrase = '',
    this.autoSync = false,
  });

  SyncConfig copyWith({
    String? remoteUrl,
    String? apiToken,
    String? passphrase,
    bool? autoSync,
  }) {
    return SyncConfig(
      remoteUrl: remoteUrl ?? this.remoteUrl,
      apiToken: apiToken ?? this.apiToken,
      passphrase: passphrase ?? this.passphrase,
      autoSync: autoSync ?? this.autoSync,
    );
  }

  Map<String, dynamic> toJson() => {
        'remote_url': remoteUrl,
        'api_token': apiToken,
        'passphrase': passphrase,
        'auto_sync': autoSync,
      };

  factory SyncConfig.fromJson(Map<String, dynamic> json) {
    return SyncConfig(
      remoteUrl: json['remote_url'] as String? ?? 'http://localhost:8080',
      apiToken: json['api_token'] as String? ?? '',
      passphrase: json['passphrase'] as String? ?? '',
      autoSync: json['auto_sync'] as bool? ?? false,
    );
  }
}

class SyncState {
  final SyncStatus status;
  final SyncConfig config;
  final String? lastSyncedAt;
  final String? errorMessage;
  final int appliedCount;
  final List<SyncConflict> conflicts;

  const SyncState({
    this.status = SyncStatus.idle,
    this.config = const SyncConfig(),
    this.lastSyncedAt,
    this.errorMessage,
    this.appliedCount = 0,
    this.conflicts = const [],
  });

  SyncState copyWith({
    SyncStatus? status,
    SyncConfig? config,
    String? lastSyncedAt,
    String? errorMessage,
    int? appliedCount,
    List<SyncConflict>? conflicts,
  }) {
    return SyncState(
      status: status ?? this.status,
      config: config ?? this.config,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      errorMessage: errorMessage,
      appliedCount: appliedCount ?? this.appliedCount,
      conflicts: conflicts ?? this.conflicts,
    );
  }
}

final syncServiceProvider = Provider<SpinelSyncService>((ref) {
  return SpinelSyncService();
});

class SyncNotifier extends Notifier<SyncState> {
  @override
  SyncState build() {
    return const SyncState();
  }

  void loadConfigForVault(String? vaultPath) {
    if (vaultPath == null) return;
    final configFile = File(p.join(vaultPath, '.spinel', 'config.json'));
    if (configFile.existsSync()) {
      try {
        final data = jsonDecode(configFile.readAsStringSync()) as Map<String, dynamic>;
        state = state.copyWith(config: SyncConfig.fromJson(data));
      } catch (_) {}
    }
  }

  void updateConfig(String? vaultPath, SyncConfig newConfig) {
    state = state.copyWith(config: newConfig);
    if (vaultPath != null) {
      final configDir = Directory(p.join(vaultPath, '.spinel'));
      if (!configDir.existsSync()) {
        configDir.createSync(recursive: true);
      }
      final configFile = File(p.join(vaultPath, '.spinel', 'config.json'));
      configFile.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(newConfig.toJson()));
    }
  }

  Future<void> triggerSync(String? vaultPath) async {
    if (vaultPath == null || state.status == SyncStatus.syncing) return;

    if (state.config.apiToken.trim().isEmpty) {
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: 'API Token is missing. Configure sync settings first.',
      );
      return;
    }

    state = state.copyWith(status: SyncStatus.syncing, errorMessage: null);

    final service = ref.read(syncServiceProvider);
    final result = await service.performSync(
      vaultPath: vaultPath,
      remoteUrl: state.config.remoteUrl,
      apiToken: state.config.apiToken,
      passphrase: state.config.passphrase,
      sinceTimestamp: state.lastSyncedAt,
    );

    if (result.success) {
      if (result.conflicts.isNotEmpty) {
        state = state.copyWith(
          status: SyncStatus.conflict,
          lastSyncedAt: result.syncedAt,
          appliedCount: result.appliedCount,
          conflicts: result.conflicts,
        );
      } else {
        state = state.copyWith(
          status: SyncStatus.synced,
          lastSyncedAt: result.syncedAt,
          appliedCount: result.appliedCount,
          conflicts: [],
        );
      }
      // Invalidate file tree to reflect any new files from server
      ref.invalidate(vaultNodesProvider);
    } else {
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: result.errorMessage ?? 'Sync failed.',
      );
    }
  }

  Future<void> resolveConflict({
    required String? vaultPath,
    required SyncConflict conflict,
    required ConflictResolutionStrategy strategy,
  }) async {
    if (vaultPath == null) return;
    final service = ref.read(syncServiceProvider);
    await service.resolveConflict(
      vaultPath: vaultPath,
      conflict: conflict,
      strategy: strategy,
    );

    final remaining = state.conflicts.where((c) => c.relativePath != conflict.relativePath).toList();
    state = state.copyWith(
      conflicts: remaining,
      status: remaining.isEmpty ? SyncStatus.synced : SyncStatus.conflict,
    );
    ref.invalidate(vaultNodesProvider);
  }
}

final syncProvider = NotifierProvider<SyncNotifier, SyncState>(() {
  return SyncNotifier();
});
