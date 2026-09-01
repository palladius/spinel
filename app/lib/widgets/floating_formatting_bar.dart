import 'package:flutter/material.dart';
import 'package:app/theme/spinel_theme.dart';

class FloatingFormattingBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onChanged;

  const FloatingFormattingBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  void _wrapSelection(String prefix, String suffix) {
    final text = controller.text;
    final selection = controller.selection;
    if (!selection.isValid) return;

    final selectedText = text.substring(selection.start, selection.end);
    final replacement = '$prefix$selectedText$suffix';
    final newText = text.replaceRange(selection.start, selection.end, replacement);

    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection(
        baseOffset: selection.start + prefix.length,
        extentOffset: selection.start + prefix.length + selectedText.length,
      ),
    );
    onChanged();
  }

  void _prefixLines(String prefix) {
    final text = controller.text;
    final selection = controller.selection;
    final start = selection.isValid ? selection.start : 0;

    // Find start of current line
    final lastNewline = text.lastIndexOf('\n', start - 1);
    final lineStart = lastNewline == -1 ? 0 : lastNewline + 1;

    final newText = text.replaceRange(lineStart, lineStart, prefix);
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + prefix.length),
    );
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: SpinelTheme.darkCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: SpinelTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _barButton(icon: Icons.title, label: 'H1', onTap: () => _prefixLines('# ')),
          _barButton(icon: Icons.format_size, label: 'H2', onTap: () => _prefixLines('## ')),
          _barButton(icon: Icons.text_fields, label: 'H3', onTap: () => _prefixLines('### ')),
          const SizedBox(width: 4),
          _divider(),
          const SizedBox(width: 4),
          _barButton(icon: Icons.format_bold, label: 'B', onTap: () => _wrapSelection('**', '**')),
          _barButton(icon: Icons.format_italic, label: 'I', onTap: () => _wrapSelection('*', '*')),
          _barButton(icon: Icons.format_underlined, label: 'U', onTap: () => _wrapSelection('<u>', '</u>')),
          _barButton(icon: Icons.strikethrough_s, label: 'S', onTap: () => _wrapSelection('~~', '~~')),
          const SizedBox(width: 4),
          _divider(),
          const SizedBox(width: 4),
          _barButton(icon: Icons.format_list_bulleted, label: '•', onTap: () => _prefixLines('- ')),
          _barButton(icon: Icons.check_box_outlined, label: '[ ]', onTap: () => _prefixLines('- [ ] ')),
          _barButton(icon: Icons.code, label: '<>', onTap: () => _wrapSelection('`', '`')),
          _barButton(icon: Icons.link, label: '🔗', onTap: () => _wrapSelection('[', '](https://)')),
        ],
      ),
    );
  }

  Widget _barButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: SpinelTheme.brightText),
            if (label.length <= 2 && label != '•' && label != '[ ]' && label != '<>' && label != '🔗') ...[
              const SizedBox(width: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: SpinelTheme.rubyAccent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 18,
      color: SpinelTheme.borderColor,
    );
  }
}
