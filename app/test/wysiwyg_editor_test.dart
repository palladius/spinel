import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/editor/live_preview_controller.dart';
import 'package:app/editor/slash_command_overlay.dart';
import 'package:app/editor/autocomplete_overlay.dart';
import 'package:app/models/note_document.dart';
import 'package:app/state/vault_provider.dart';
import 'package:app/widgets/dual_mode_editor.dart';

void main() {
  group('SpinelLivePreviewController', () {
    testWidgets('builds styled text spans for markdown tokens', (tester) async {
      late SpinelLivePreviewController controller;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                controller = SpinelLivePreviewController(
                  text: '# Heading 1\n**bold text** and `code span`\n- [ ] Task 1',
                  isLivePreviewEnabled: true,
                );
                final span = controller.buildTextSpan(
                  context: context,
                  withComposing: false,
                );
                return Text.rich(span);
              },
            ),
          ),
        ),
      );

      expect(find.byType(RichText), findsWidgets);
    });
  });

  group('SlashCommandMenu Widget', () {
    testWidgets('renders all slash commands and triggers selection', (tester) async {
      SlashCommandItem? selectedItem;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SlashCommandMenu(
              onSelect: (item) => selectedItem = item,
              onDismiss: () {},
            ),
          ),
        ),
      );

      expect(find.text('SLASH COMMANDS'), findsOneWidget);
      expect(find.text('Heading 1'), findsOneWidget);
      expect(find.text('Heading 2'), findsOneWidget);
      expect(find.text('To-do List'), findsOneWidget);

      await tester.tap(find.text('Heading 1'));
      await tester.pumpAndSettle();

      expect(selectedItem, isNotNull);
      expect(selectedItem!.title, equals('Heading 1'));
      expect(selectedItem!.insertionText, equals('# '));
    });
  });

  group('AutocompleteOverlay Widget', () {
    testWidgets('renders suggestions and handles selection', (tester) async {
      String? chosen;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AutocompleteOverlay(
              title: 'Note Links',
              suggestions: const ['Architecture', 'Daily Notes'],
              onSelected: (val) => chosen = val,
              onDismiss: () {},
            ),
          ),
        ),
      );

      expect(find.text('NOTE LINKS'), findsOneWidget);
      expect(find.text('Architecture'), findsOneWidget);

      await tester.tap(find.text('Architecture'));
      await tester.pumpAndSettle();

      expect(chosen, equals('Architecture'));
    });
  });

  group('DualModeEditor Integration', () {
    testWidgets('renders in split view with raw editor and visual markdown', (tester) async {
      final doc = NoteDocument.parse(
        filePath: '/vault/note.md',
        relativePath: 'note.md',
        content: '# Test Document\nBody content.',
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: DualModeEditor(
                document: doc,
                mode: EditorViewMode.splitView,
                onBodyChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Test Document'), findsWidgets);
    });
  });
}
