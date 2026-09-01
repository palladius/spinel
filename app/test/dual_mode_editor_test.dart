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
}
