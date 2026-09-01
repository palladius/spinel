import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app/models/note_document.dart';
import 'package:app/state/vault_provider.dart';
import 'package:app/theme/spinel_theme.dart';
import 'package:app/widgets/floating_formatting_bar.dart';

class DualModeEditor extends StatefulWidget {
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
  State<DualModeEditor> createState() => _DualModeEditorState();
}

class _DualModeEditorState extends State<DualModeEditor> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.document.body);
  }

  @override
  void didUpdateWidget(covariant DualModeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document.filePath != widget.document.filePath) {
      _textController.text = widget.document.body;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top floating formatting toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          alignment: Alignment.centerLeft,
          child: FloatingFormattingBar(
            controller: _textController,
            onChanged: () {
              setState(() {
                widget.onBodyChanged(_textController.text);
              });
            },
          ),
        ),
        Expanded(
          child: _buildEditorBody(),
        ),
      ],
    );
  }

  Widget _buildEditorBody() {
    switch (widget.mode) {
      case EditorViewMode.rawMarkdown:
        return _buildRawEditor();
      case EditorViewMode.renderedWysiwyg:
        return _buildRenderedView();
      case EditorViewMode.splitView:
        return Row(
          children: [
            Expanded(child: _buildRawEditor()),
            const VerticalDivider(color: SpinelTheme.borderColor, width: 1),
            Expanded(child: _buildRenderedView()),
          ],
        );
    }
  }

  Widget _buildRawEditor() {
    return Container(
      color: SpinelTheme.darkBase,
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _textController,
        maxLines: null,
        expands: true,
        style: GoogleFonts.jetBrainsMono(
          color: SpinelTheme.brightText,
          fontSize: 13,
          height: 1.5,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'Start writing Markdown...',
          hintStyle: TextStyle(color: SpinelTheme.slateText),
        ),
        onChanged: (val) {
          widget.onBodyChanged(val);
          setState(() {});
        },
      ),
    );
  }

  Widget _buildRenderedView() {
    return Container(
      color: SpinelTheme.darkSurface,
      padding: const EdgeInsets.all(20),
      child: Markdown(
        data: _textController.text,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: SpinelTheme.rubyAccent),
          h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SpinelTheme.brightText),
          h3: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SpinelTheme.rubyGlow),
          p: const TextStyle(fontSize: 13, color: SpinelTheme.brightText, height: 1.6),
          code: GoogleFonts.jetBrainsMono(backgroundColor: SpinelTheme.darkCard, color: SpinelTheme.rubyAccent, fontSize: 12),
          codeblockDecoration: BoxDecoration(
            color: SpinelTheme.darkCard,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: SpinelTheme.borderColor),
          ),
          blockquoteDecoration: BoxDecoration(
            border: const Border(left: BorderSide(color: SpinelTheme.rubyAccent, width: 3)),
            color: SpinelTheme.darkCard.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
