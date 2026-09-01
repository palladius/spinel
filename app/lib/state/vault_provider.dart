import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/models/note_document.dart';
import 'package:app/services/vault_service.dart';

final vaultServiceProvider = Provider<VaultService>((ref) => VaultService());

class VaultPathNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void setPath(String? path) => state = path;
}
final vaultPathProvider = NotifierProvider<VaultPathNotifier, String?>(VaultPathNotifier.new);

final vaultNodesProvider = FutureProvider<List<VaultFileNode>>((ref) async {
  final path = ref.watch(vaultPathProvider);
  if (path == null) return [];
  final service = ref.watch(vaultServiceProvider);
  return service.scanVault(path);
});

class SelectedNoteNotifier extends Notifier<NoteDocument?> {
  @override
  NoteDocument? build() => null;
  void setNote(NoteDocument? note) => state = note;
}
final selectedNoteProvider = NotifierProvider<SelectedNoteNotifier, NoteDocument?>(SelectedNoteNotifier.new);

enum EditorViewMode {
  rawMarkdown,
  renderedWysiwyg,
  splitView,
}

class EditorModeNotifier extends Notifier<EditorViewMode> {
  @override
  EditorViewMode build() => EditorViewMode.splitView;
  void setMode(EditorViewMode mode) => state = mode;
}
final editorModeProvider = NotifierProvider<EditorModeNotifier, EditorViewMode>(EditorModeNotifier.new);
