import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/models/note_document.dart';
import 'package:app/state/vault_provider.dart';
import 'package:app/theme/spinel_theme.dart';
import 'package:app/widgets/dual_mode_editor.dart';

void main() {
  testWidgets('DualModeEditor renders raw editor and WYSIWYG view', (WidgetTester tester) async {
    final doc = NoteDocument(
      filePath: '/tmp/note.md',
      relativePath: 'note.md',
      frontmatter: {'title': 'My Title'},
      body: '# Main Header\n- [x] Done item\n- [ ] Pending item',
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: SpinelTheme.darkTheme,
          home: Scaffold(
            body: DualModeEditor(
              document: doc,
              mode: EditorViewMode.splitView,
              onBodyChanged: (val) {},
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify formatting bar buttons exist
    expect(find.byIcon(Icons.format_bold), findsOneWidget);
    expect(find.byIcon(Icons.format_italic), findsOneWidget);
    expect(find.byIcon(Icons.check_box_outlined), findsOneWidget);

    // Verify raw text field contains markdown text
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('editing markdown on the left instantly updates rendered preview on the right', (WidgetTester tester) async {
    String currentBody = 'pinco pallo';
    final doc = NoteDocument(
      filePath: '/tmp/note.md',
      relativePath: 'note.md',
      frontmatter: {},
      body: currentBody,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: SpinelTheme.darkTheme,
          home: Scaffold(
            body: DualModeEditor(
              document: doc,
              mode: EditorViewMode.splitView,
              onBodyChanged: (newBody) {
                currentBody = newBody;
              },
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial text appears in preview
    expect(find.text('pinco pallo'), findsWidgets);

    // Edit text field on the left by typing "pinco sempronio pallo"
    await tester.enterText(find.byType(TextField), '# Heading\npinco sempronio pallo');
    await tester.pump();

    // Verify callback was triggered
    expect(currentBody, equals('# Heading\npinco sempronio pallo'));

    // Verify the preview on the right immediately re-rendered with new text
    expect(find.text('pinco sempronio pallo'), findsOneWidget);
    expect(find.text('Heading'), findsOneWidget);
  });
}
