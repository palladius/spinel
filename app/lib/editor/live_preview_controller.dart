import 'package:flutter/material.dart';
import 'package:app/theme/spinel_theme.dart';

class SpinelLivePreviewController extends TextEditingController {
  bool isLivePreviewEnabled;

  SpinelLivePreviewController({
    String? text,
    this.isLivePreviewEnabled = true,
  }) : super(text: text);

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (!isLivePreviewEnabled || text.isEmpty) {
      return super.buildTextSpan(context: context, style: style, withComposing: withComposing);
    }

    final baseStyle = style ?? const TextStyle(color: SpinelTheme.brightText, fontSize: 14, height: 1.6);
    final spans = <InlineSpan>[];

    final cursorOffset = selection.baseOffset;
    final lines = text.split('\n');
    int currentOffset = 0;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineStart = currentOffset;
      final lineEnd = lineStart + line.length;
      final isCursorOnLine = cursorOffset >= lineStart && cursorOffset <= lineEnd;

      if (isCursorOnLine) {
        // Line being edited: Render with syntax highlighting while keeping raw tokens visible
        spans.add(_buildActiveLineSpan(line, baseStyle));
      } else {
        // Line not being edited: Render rich WYSIWYG formatting
        spans.add(_buildInactiveLineSpan(line, baseStyle));
      }

      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }

      currentOffset += line.length + 1; // +1 for '\n'
    }

    return TextSpan(children: spans, style: baseStyle);
  }

  InlineSpan _buildActiveLineSpan(String line, TextStyle baseStyle) {
    if (line.startsWith('# ')) {
      return TextSpan(
        children: [
          const TextSpan(text: '# ', style: TextStyle(color: SpinelTheme.rubyBright, fontWeight: FontWeight.bold)),
          TextSpan(text: line.substring(2), style: baseStyle.copyWith(fontSize: 22, fontWeight: FontWeight.bold, color: SpinelTheme.brightText)),
        ],
      );
    } else if (line.startsWith('## ')) {
      return TextSpan(
        children: [
          const TextSpan(text: '## ', style: TextStyle(color: SpinelTheme.rubyBright, fontWeight: FontWeight.bold)),
          TextSpan(text: line.substring(3), style: baseStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: SpinelTheme.brightText)),
        ],
      );
    } else if (line.startsWith('### ')) {
      return TextSpan(
        children: [
          const TextSpan(text: '### ', style: TextStyle(color: SpinelTheme.rubyBright, fontWeight: FontWeight.bold)),
          TextSpan(text: line.substring(4), style: baseStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: SpinelTheme.brightText)),
        ],
      );
    } else if (line.startsWith('- [ ] ') || line.startsWith('- [x] ')) {
      final isChecked = line.startsWith('- [x] ');
      return TextSpan(
        children: [
          TextSpan(
            text: isChecked ? '☑ ' : '☐ ',
            style: TextStyle(color: isChecked ? SpinelTheme.rubyBright : SpinelTheme.slateText, fontWeight: FontWeight.bold),
          ),
          TextSpan(text: line.substring(6), style: baseStyle.copyWith(decoration: isChecked ? TextDecoration.lineThrough : null)),
        ],
      );
    }

    return _parseInlineSpans(line, baseStyle, isActive: true);
  }

  InlineSpan _buildInactiveLineSpan(String line, TextStyle baseStyle) {
    if (line.startsWith('# ')) {
      return TextSpan(text: line.substring(2), style: baseStyle.copyWith(fontSize: 22, fontWeight: FontWeight.bold, color: SpinelTheme.brightText));
    } else if (line.startsWith('## ')) {
      return TextSpan(text: line.substring(3), style: baseStyle.copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: SpinelTheme.brightText));
    } else if (line.startsWith('### ')) {
      return TextSpan(text: line.substring(4), style: baseStyle.copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: SpinelTheme.brightText));
    } else if (line.startsWith('- [ ] ') || line.startsWith('- [x] ')) {
      final isChecked = line.startsWith('- [x] ');
      return TextSpan(
        children: [
          TextSpan(
            text: isChecked ? '☑ ' : '☐ ',
            style: TextStyle(
              fontSize: 15,
              color: isChecked ? SpinelTheme.rubyBright : SpinelTheme.slateText,
              fontWeight: FontWeight.bold,
            ),
          ),
          _parseInlineSpans(
            line.substring(6),
            baseStyle.copyWith(
              color: isChecked ? SpinelTheme.slateText : SpinelTheme.brightText,
              decoration: isChecked ? TextDecoration.lineThrough : null,
            ),
            isActive: false,
          ),
        ],
      );
    } else if (line.startsWith('> ')) {
      return TextSpan(
        text: '▎ ${line.substring(2)}',
        style: baseStyle.copyWith(fontStyle: FontStyle.italic, color: SpinelTheme.rubyLight),
      );
    }

    return _parseInlineSpans(line, baseStyle, isActive: false);
  }

  InlineSpan _parseInlineSpans(String text, TextStyle baseStyle, {required bool isActive}) {
    // Regex for inline tokens: **bold**, *italic*, `code`, [[wikilink]], #tag
    final regex = RegExp(r'(\*\*[^*]+\*\*|\*[^*]+\*|`[^`]+`|\[\[[^\]]+\]\]|#[a-zA-Z0-9_\-]+)');
    final matches = regex.allMatches(text);

    if (matches.isEmpty) {
      return TextSpan(text: text, style: baseStyle);
    }

    final children = <InlineSpan>[];
    int lastIndex = 0;

    for (final match in matches) {
      if (match.start > lastIndex) {
        children.add(TextSpan(text: text.substring(lastIndex, match.start), style: baseStyle));
      }

      final matchedText = match.group(0)!;

      if (matchedText.startsWith('**') && matchedText.endsWith('**')) {
        final content = matchedText.substring(2, matchedText.length - 2);
        children.add(TextSpan(
          text: isActive ? matchedText : content,
          style: baseStyle.copyWith(fontWeight: FontWeight.bold, color: SpinelTheme.brightText),
        ));
      } else if (matchedText.startsWith('*') && matchedText.endsWith('*')) {
        final content = matchedText.substring(1, matchedText.length - 1);
        children.add(TextSpan(
          text: isActive ? matchedText : content,
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      } else if (matchedText.startsWith('`') && matchedText.endsWith('`')) {
        final content = matchedText.substring(1, matchedText.length - 1);
        children.add(TextSpan(
          text: isActive ? matchedText : content,
          style: baseStyle.copyWith(
            fontFamily: 'monospace',
            backgroundColor: SpinelTheme.darkCard,
            color: SpinelTheme.rubyBright,
          ),
        ));
      } else if (matchedText.startsWith('[[') && matchedText.endsWith(']]')) {
        final link = matchedText.substring(2, matchedText.length - 2);
        children.add(TextSpan(
          text: isActive ? matchedText : link,
          style: baseStyle.copyWith(
            color: Colors.lightBlueAccent,
            decoration: TextDecoration.underline,
          ),
        ));
      } else if (matchedText.startsWith('#')) {
        children.add(TextSpan(
          text: matchedText,
          style: baseStyle.copyWith(
            color: SpinelTheme.rubyLight,
            fontWeight: FontWeight.w600,
          ),
        ));
      } else {
        children.add(TextSpan(text: matchedText, style: baseStyle));
      }

      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      children.add(TextSpan(text: text.substring(lastIndex), style: baseStyle));
    }

    return TextSpan(children: children, style: baseStyle);
  }
}
