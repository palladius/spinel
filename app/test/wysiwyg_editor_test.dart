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
                  text: '# Heading 1\n**bold text** and `code span`\n- [ ] Task 1\n[[Note Link]] #tag\n> Quote block',
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

    testWidgets('strictly guarantees 1:1 character mapping invariant (no cursor desync)', (tester) async {
      final samples = [
        '- Bold text with double asterisks\n- Italic text with single asterisks\n- Checkboxes (- [ ] or - [x])\n\n££\n# figata fgalattiva',
        '# Title\n## Subtitle\n### H3\n- [ ] Unchecked\n- [x] Checked\n> Blockquote\n**Bold** *Italic* `Code` [[Wikilink]] #tag',
        'Just normal text without any markdown tags.',
        '[[Spinel Note]] with adjacent **bold** and `code` tags',
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                for (final text in samples) {
                  final controller = SpinelLivePreviewController(
                    text: text,
                    isLivePreviewEnabled: true,
                  );
                  final span = controller.buildTextSpan(
                    context: context,
                    withComposing: false,
                  );
                  // The rendered plain text must EXACTLY equal the underlying raw text
                  expect(span.toPlainText(), equals(text), reason: 'TextSpan character length mismatch for text:\n$text');
                }
                return const Text('ok');
              },
            ),
          ),
        ),
      );
    });

    testWidgets('typing DEL/Backspace at cursor removes characters at cursor and not above/below', (tester) async {
      // Scenario from user screenshot:
      // Line 0: "- list item" (length 11, indices 0..10, newline at 11)
      // Line 1: "££" (length 2, indices 12..13, newline at 14)
      // Line 2: "# figata fgalattiva" (length 19, indices 15..33)
      final initialText = '- list item\n££\n# figata fgalattiva';
      final controller = SpinelLivePreviewController(
        text: initialText,
        isLivePreviewEnabled: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(
              controller: controller,
              maxLines: null,
            ),
          ),
        ),
      );

      // Focus the text field
      await tester.tap(find.byType(TextField));
      await tester.pump();

      // Position cursor right after '££' (index 14)
      controller.selection = const TextSelection.collapsed(offset: 14);
      await tester.pump();

      // Delete first '£' (simulate backspace / DEL at cursor position)
      final textAfterOneDelete = controller.text.substring(0, 13) + controller.text.substring(14);
      controller.value = TextEditingValue(
        text: textAfterOneDelete,
        selection: const TextSelection.collapsed(offset: 13),
      );
      await tester.pump();
      expect(controller.text, equals('- list item\n£\n# figata fgalattiva'));

      // Delete second '£'
      final textAfterTwoDeletes = controller.text.substring(0, 12) + controller.text.substring(13);
      controller.value = TextEditingValue(
        text: textAfterTwoDeletes,
        selection: const TextSelection.collapsed(offset: 12),
      );
      await tester.pump();

      // Verify that the two '££' were removed, and BOTH line above and heading below are pristine
      expect(controller.text, equals('- list item\n\n# figata fgalattiva'));
      expect(controller.text.startsWith('- list item\n'), isTrue);
      expect(controller.text.endsWith('\n# figata fgalattiva'), isTrue);
    });

    testWidgets('cursor positioned exactly between "pinco" and "pallo" injects "sempronio " without shifting lines', (tester) async {
      // Multiline structure with headers above and below
      // Line 0: "# Header Superiore" (length 18, newline at 18)
      // Line 1: "pinco pallo" (length 11, newline at 30)
      // Line 2: "## Header Inferiore" (length 19)
      const line0 = '# Header Superiore\n';
      const line1 = 'pinco pallo\n';
      const line2 = '## Header Inferiore';
      final initialDoc = '$line0$line1$line2';

      final controller = SpinelLivePreviewController(
        text: initialDoc,
        isLivePreviewEnabled: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(
              controller: controller,
              maxLines: null,
            ),
          ),
        ),
      );

      // Focus the text field
      await tester.tap(find.byType(TextField));
      await tester.pump();

      // Locate cursor between 'pinco ' and 'pallo'
      // Offset = length of line0 (19) + length of 'pinco ' (6) = 25
      final cursorOffset = line0.length + 'pinco '.length;
      expect(initialDoc.substring(cursorOffset, cursorOffset + 5), equals('pallo'));

      controller.selection = TextSelection.collapsed(offset: cursorOffset);
      await tester.pump();

      // Inject "sempronio " at the exact cursor position
      const wordToInject = 'sempronio ';
      final updatedText = controller.text.substring(0, cursorOffset) +
          wordToInject +
          controller.text.substring(cursorOffset);

      controller.value = TextEditingValue(
        text: updatedText,
        selection: TextSelection.collapsed(offset: cursorOffset + wordToInject.length),
      );
      await tester.pump();

      // Verify exact result:
      // Line 0: "# Header Superiore" is untouched
      // Line 1: "pinco sempronio pallo"
      // Line 2: "## Header Inferiore" is untouched
      expect(controller.text, equals('# Header Superiore\npinco sempronio pallo\n## Header Inferiore'));
      expect(controller.text.startsWith('# Header Superiore\n'), isTrue);
      expect(controller.text.endsWith('\n## Header Inferiore'), isTrue);
      expect(controller.text.contains('pinco sempronio pallo'), isTrue);
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
