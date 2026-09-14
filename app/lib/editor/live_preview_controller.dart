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

    final baseStyle = style ?? const TextStyle(color: SpinelTheme.brightText, fontSize: 13, height: 1.45);
    final spans = <InlineSpan>[];
    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      spans.add(_buildLineSpan(lines[i], baseStyle));
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return TextSpan(children: spans, style: baseStyle);
  }

  InlineSpan _buildLineSpan(String line, TextStyle baseStyle) {
    if (line.startsWith('# ')) {
      final headingStyle = baseStyle.copyWith(fontWeight: FontWeight.bold, color: SpinelTheme.brightText);
      return TextSpan(
        children: [
          TextSpan(text: '# ', style: headingStyle.copyWith(color: SpinelTheme.rubyPrimary, fontWeight: FontWeight.bold)),
          _parseInlineSpans(line.substring(2), headingStyle),
        ],
      );
    } else if (line.startsWith('## ')) {
      final headingStyle = baseStyle.copyWith(fontWeight: FontWeight.bold, color: SpinelTheme.brightText);
      return TextSpan(
        children: [
          TextSpan(text: '## ', style: headingStyle.copyWith(color: SpinelTheme.rubyPrimary, fontWeight: FontWeight.bold)),
          _parseInlineSpans(line.substring(3), headingStyle),
        ],
      );
    } else if (line.startsWith('### ')) {
      final headingStyle = baseStyle.copyWith(fontWeight: FontWeight.w600, color: SpinelTheme.brightText);
      return TextSpan(
        children: [
          TextSpan(text: '### ', style: headingStyle.copyWith(color: SpinelTheme.rubyPrimary, fontWeight: FontWeight.bold)),
          _parseInlineSpans(line.substring(4), headingStyle),
        ],
      );
    } else if (line.startsWith('- [ ] ') || line.startsWith('- [x] ') || line.startsWith('* [ ] ') || line.startsWith('* [x] ')) {
      final isChecked = line[3] == 'x' || line[3] == 'X';
      final prefix = line.substring(0, 6);
      return TextSpan(
        children: [
          TextSpan(
            text: prefix,
            style: baseStyle.copyWith(
              color: isChecked ? SpinelTheme.rubyBright : SpinelTheme.slateMuted,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          _parseInlineSpans(
            line.substring(6),
            baseStyle.copyWith(
              color: isChecked ? SpinelTheme.slateText : SpinelTheme.brightText,
              decoration: isChecked ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      );
    } else if (line.startsWith('> ')) {
      return TextSpan(
        children: [
          TextSpan(text: '> ', style: baseStyle.copyWith(color: SpinelTheme.rubyPrimary, fontWeight: FontWeight.bold)),
          _parseInlineSpans(line.substring(2), baseStyle.copyWith(fontStyle: FontStyle.italic, color: SpinelTheme.rubyLight)),
        ],
      );
    }

    return _parseInlineSpans(line, baseStyle);
  }

  InlineSpan _parseInlineSpans(String text, TextStyle baseStyle) {
    if (text.isEmpty) {
      return TextSpan(text: '', style: baseStyle);
    }

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

      if (matchedText.startsWith('**') && matchedText.endsWith('**') && matchedText.length >= 4) {
        children.add(TextSpan(
          text: '**',
          style: baseStyle.copyWith(color: SpinelTheme.rubyPrimary.withOpacity(0.6), fontWeight: FontWeight.bold),
        ));
        children.add(TextSpan(
          text: matchedText.substring(2, matchedText.length - 2),
          style: baseStyle.copyWith(fontWeight: FontWeight.bold, color: SpinelTheme.brightText),
        ));
        children.add(TextSpan(
          text: '**',
          style: baseStyle.copyWith(color: SpinelTheme.rubyPrimary.withOpacity(0.6), fontWeight: FontWeight.bold),
        ));
      } else if (matchedText.startsWith('*') && matchedText.endsWith('*') && matchedText.length >= 2) {
        children.add(TextSpan(
          text: '*',
          style: baseStyle.copyWith(color: SpinelTheme.rubyPrimary.withOpacity(0.6)),
        ));
        children.add(TextSpan(
          text: matchedText.substring(1, matchedText.length - 1),
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ));
        children.add(TextSpan(
          text: '*',
          style: baseStyle.copyWith(color: SpinelTheme.rubyPrimary.withOpacity(0.6)),
        ));
      } else if (matchedText.startsWith('`') && matchedText.endsWith('`') && matchedText.length >= 2) {
        children.add(TextSpan(
          text: matchedText,
          style: baseStyle.copyWith(
            fontFamily: 'monospace',
            backgroundColor: SpinelTheme.darkCard,
            color: SpinelTheme.rubyLight,
          ),
        ));
      } else if (matchedText.startsWith('[[') && matchedText.endsWith(']]') && matchedText.length >= 4) {
        children.add(TextSpan(
          text: '[[',
          style: baseStyle.copyWith(color: SpinelTheme.rubyPrimary.withOpacity(0.7)),
        ));
        children.add(TextSpan(
          text: matchedText.substring(2, matchedText.length - 2),
          style: baseStyle.copyWith(
            color: Colors.lightBlueAccent,
            decoration: TextDecoration.underline,
          ),
        ));
        children.add(TextSpan(
          text: ']]',
          style: baseStyle.copyWith(color: SpinelTheme.rubyPrimary.withOpacity(0.7)),
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
