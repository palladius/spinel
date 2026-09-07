import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/editor/live_preview_controller.dart';
import 'package:app/editor/slash_command_overlay.dart';
import 'package:app/editor/autocomplete_overlay.dart';
import 'package:app/models/note_document.dart';
import 'package:app/state/vault_provider.dart';
import 'package:app/theme/spinel_theme.dart';
import 'package:app/widgets/floating_formatting_bar.dart';

class DualModeEditor extends ConsumerStatefulWidget {
  final NoteDocument document;
  final EditorViewMode mode;
  final ValueChanged<String> onBodyChanged;

  const DualModeEditor({
    super.key,
    required this.document,
    required this.mode,
    required this.onBodyChanged,
  });

  @override
  ConsumerState<DualModeEditor> createState() => _DualModeEditorState();
}

class _DualModeEditorState extends ConsumerState<DualModeEditor> {
  late SpinelLivePreviewController _controller;
  bool _showSlashMenu = false;
  bool _showWikilinkMenu = false;

  @override
  void initState() {
    super.initState();
    _controller = SpinelLivePreviewController(
      text: widget.document.body,
      isLivePreviewEnabled: widget.mode == EditorViewMode.renderedWysiwyg || widget.mode == EditorViewMode.splitView,
    );
    _controller.addListener(_handleTextChange);
  }

  @override
  void didUpdateWidget(covariant DualModeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document.filePath != widget.document.filePath) {
      _controller.text = widget.document.body;
    }
    _controller.isLivePreviewEnabled = widget.mode == EditorViewMode.renderedWysiwyg || widget.mode == EditorViewMode.splitView;
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    _controller.dispose();
    super.dispose();
  }

  void _handleTextChange() {
    final newText = _controller.text;
    if (newText != widget.document.body) {
      widget.onBodyChanged(newText);
    }

    final selection = _controller.selection;
    if (!selection.isValid || selection.baseOffset < 0) {
      _hideOverlays();
      return;
    }

    final offset = selection.baseOffset;
    final textBeforeCaret = newText.substring(0, offset);

    // Check for Slash Command trigger: "/" at line start or after space
    if (textBeforeCaret.endsWith('/') && (textBeforeCaret.length == 1 || textBeforeCaret[textBeforeCaret.length - 2] == '\n' || textBeforeCaret[textBeforeCaret.length - 2] == ' ')) {
      setState(() {
        _showSlashMenu = true;
        _showWikilinkMenu = false;
      });
    } else if (textBeforeCaret.endsWith('[[')) {
      setState(() {
        _showWikilinkMenu = true;
        _showSlashMenu = false;
      });
    } else if (!textBeforeCaret.contains('/') && !textBeforeCaret.contains('[[')) {
      _hideOverlays();
    }
  }

  void _hideOverlays() {
    if (_showSlashMenu || _showWikilinkMenu) {
      setState(() {
        _showSlashMenu = false;
        _showWikilinkMenu = false;
      });
    }
  }

  void _applySlashCommand(SlashCommandItem item) {
    final selection = _controller.selection;
    final text = _controller.text;
    final offset = selection.baseOffset;

    // Remove the triggering '/' and insert item
    if (offset > 0 && text[offset - 1] == '/') {
      final newText = text.substring(0, offset - 1) + item.insertionText + text.substring(offset);
      _controller.text = newText;
      final newCaret = offset - 1 + item.insertionText.length + item.cursorOffsetAdjustment;
      _controller.selection = TextSelection.collapsed(offset: newCaret);
    } else {
      final newText = text.substring(0, offset) + item.insertionText + text.substring(offset);
      _controller.text = newText;
    }
    _hideOverlays();
  }

  void _applyWikilink(String noteName) {
    final selection = _controller.selection;
    final text = _controller.text;
    final offset = selection.baseOffset;

    final insertText = '$noteName]]';
    final newText = text.substring(0, offset) + insertText + text.substring(offset);
    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(offset: offset + insertText.length);
    _hideOverlays();
  }

  @override
  Widget build(BuildContext context) {
    final nodesAsync = ref.watch(vaultNodesProvider);
    final noteSuggestions = <String>[];

    nodesAsync.whenData((nodes) {
      for (final node in nodes) {
        if (!node.isDirectory) {
          final name = node.name.endsWith('.md') ? node.name.substring(0, node.name.length - 3) : node.name;
          noteSuggestions.add(name);
        }
      }
    });

    return Stack(
      children: [
        _buildEditorLayout(),

        // Floating Formatting Bar
        Positioned(
          bottom: 24,
          right: 24,
          child: FloatingFormattingBar(
            controller: _controller,
            onChanged: () => widget.onBodyChanged(_controller.text),
          ),
        ),

        // Slash Command Popup
        if (_showSlashMenu)
          Positioned(
            top: 60,
            left: 40,
            child: SlashCommandMenu(
              onSelect: _applySlashCommand,
              onDismiss: _hideOverlays,
            ),
          ),

        // Wikilink Autocomplete Popup
        if (_showWikilinkMenu)
          Positioned(
            top: 60,
            left: 40,
            child: AutocompleteOverlay(
              title: 'Insert Note Link',
              suggestions: noteSuggestions.isNotEmpty ? noteSuggestions : ['Sample Note', 'Project Architecture'],
              onSelected: _applyWikilink,
              onDismiss: _hideOverlays,
            ),
          ),
      ],
    );
  }

  Widget _buildEditorLayout() {
    switch (widget.mode) {
      case EditorViewMode.rawMarkdown:
        return _buildRawEditor();
      case EditorViewMode.renderedWysiwyg:
        return _buildVisualView();
      case EditorViewMode.splitView:
        return Row(
          children: [
            Expanded(child: _buildRawEditor()),
            const VerticalDivider(color: SpinelTheme.borderColor, width: 1),
            Expanded(child: _buildVisualView()),
          ],
        );
    }
  }

  Widget _buildRawEditor() {
    return Container(
      color: SpinelTheme.darkCanvas,
      padding: const EdgeInsets.all(24.0),
      child: TextField(
        controller: _controller,
        maxLines: null,
        expands: true,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13.5,
          color: SpinelTheme.brightText,
          height: 1.6,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Start writing markdown or type / for commands...',
          hintStyle: TextStyle(color: SpinelTheme.slateText),
        ),
      ),
    );
  }

  Widget _buildVisualView() {
    return Container(
      color: SpinelTheme.darkCanvas,
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      child: Markdown(
        data: _controller.text,
        selectable: true,
        styleSheet: MarkdownStyleSheet.fromTheme(SpinelTheme.darkTheme).copyWith(
          h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: SpinelTheme.brightText),
          h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: SpinelTheme.rubyBright),
          h3: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: SpinelTheme.brightText),
          p: const TextStyle(fontSize: 14, height: 1.7, color: SpinelTheme.brightText),
          code: const TextStyle(
            fontFamily: 'monospace',
            backgroundColor: SpinelTheme.darkCard,
            color: SpinelTheme.rubyLight,
          ),
          blockquoteDecoration: BoxDecoration(
            border: const Border(left: BorderSide(color: SpinelTheme.rubyPrimary, width: 3)),
            color: SpinelTheme.darkCard.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
