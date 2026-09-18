import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:app/state/vault_provider.dart';
import 'package:app/theme/spinel_theme.dart';
import 'package:app/widgets/new_note_dialog.dart';

class FakeVaultPathNotifier extends VaultPathNotifier {
  final String initial;
  FakeVaultPathNotifier(this.initial);

  @override
  String? build() => initial;
}

void main() {
  group('NewNoteDialog Component Tests', () {
    late Directory tempVault;

    setUp(() async {
      tempVault = await Directory.systemTemp.createTemp('spinel_test_vault_');
      await Directory(p.join(tempVault.path, '01_Daily_Notes')).create();
    });

    tearDown(() async {
      if (await tempVault.exists()) {
        await tempVault.delete(recursive: true);
      }
    });

    testWidgets('pre-populates title with today YYYY-MM-DD and creates note on click', (tester) async {
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vaultPathProvider.overrideWith(() => FakeVaultPathNotifier(tempVault.path)),
          ],
          child: MaterialApp(
            theme: SpinelTheme.darkTheme,
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => NewNoteDialog.show(context),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Dialog is shown
      expect(find.text('Create New Note'), findsOneWidget);

      // Verify TextField has today's date formatted as YYYY-MM-DD
      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);
      final TextField textField = tester.widget(textFieldFinder);
      expect(textField.controller?.text, equals(todayStr));

      // Click on "Create Note" button without typing anything
      final createNoteBtn = find.text('Create Note');
      expect(createNoteBtn, findsOneWidget);
      await tester.tap(createNoteBtn);
      await tester.pumpAndSettle();

      // Dialog should be dismissed
      expect(find.text('Create New Note'), findsNothing);

      // Verify file was created on disk in 01_Daily_Notes/<todayStr>.md
      final expectedFile = File(p.join(tempVault.path, '01_Daily_Notes', '$todayStr.md'));
      expect(expectedFile.existsSync(), isTrue, reason: 'File $todayStr.md should exist in 01_Daily_Notes');
    });

    testWidgets('falls back to today date if title is cleared', (tester) async {
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vaultPathProvider.overrideWith(() => FakeVaultPathNotifier(tempVault.path)),
          ],
          child: MaterialApp(
            theme: SpinelTheme.darkTheme,
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => NewNoteDialog.show(context),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Clear the text
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();

      // Click Create Note
      await tester.tap(find.text('Create Note'));
      await tester.pumpAndSettle();

      // Dialog should be dismissed and fallback to todayStr
      expect(find.text('Create New Note'), findsNothing);
      final expectedFile = File(p.join(tempVault.path, '01_Daily_Notes', '$todayStr.md'));
      expect(expectedFile.existsSync(), isTrue);
    });

    testWidgets('allows custom title', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            vaultPathProvider.overrideWith(() => FakeVaultPathNotifier(tempVault.path)),
          ],
          child: MaterialApp(
            theme: SpinelTheme.darkTheme,
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => NewNoteDialog.show(context),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Enter custom title
      await tester.enterText(find.byType(TextField), 'SRE Architecture');
      await tester.pump();

      // Click Create Note
      await tester.tap(find.text('Create Note'));
      await tester.pumpAndSettle();

      expect(find.text('Create New Note'), findsNothing);
      final expectedFile = File(p.join(tempVault.path, '01_Daily_Notes', 'sre_architecture.md'));
      expect(expectedFile.existsSync(), isTrue);
    });
  });
}
