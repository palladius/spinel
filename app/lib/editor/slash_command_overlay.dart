import 'package:flutter/material.dart';
import 'package:app/theme/spinel_theme.dart';

class SlashCommandItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String insertionText;
  final int cursorOffsetAdjustment;

  const SlashCommandItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.insertionText,
    this.cursorOffsetAdjustment = 0,
  });
}

const List<SlashCommandItem> kSlashCommands = [
  SlashCommandItem(
    title: 'Heading 1',
    subtitle: 'Large section heading',
    icon: Icons.title,
    insertionText: '# ',
  ),
  SlashCommandItem(
    title: 'Heading 2',
    subtitle: 'Medium section heading',
    icon: Icons.format_size,
    insertionText: '## ',
  ),
  SlashCommandItem(
    title: 'Heading 3',
    subtitle: 'Small section heading',
    icon: Icons.text_fields,
    insertionText: '### ',
  ),
  SlashCommandItem(
    title: 'To-do List',
    subtitle: 'Interactive task checklist item',
    icon: Icons.check_box_outlined,
    insertionText: '- [ ] ',
  ),
  SlashCommandItem(
    title: 'Bullet List',
    subtitle: 'Standard unordered list item',
    icon: Icons.format_list_bulleted,
    insertionText: '- ',
  ),
  SlashCommandItem(
    title: 'Code Block',
    subtitle: 'Syntax-highlighted code container',
    icon: Icons.code,
    insertionText: '```\n\n```\n',
    cursorOffsetAdjustment: -5,
  ),
  SlashCommandItem(
    title: 'Quote',
    subtitle: 'Blockquote commentary',
    icon: Icons.format_quote,
    insertionText: '> ',
  ),
  SlashCommandItem(
    title: 'Callout Alert',
    subtitle: 'GitHub-style note callout box',
    icon: Icons.info_outline,
    insertionText: '> [!NOTE]\n> ',
  ),
  SlashCommandItem(
    title: 'Divider',
    subtitle: 'Horizontal section separator',
    icon: Icons.horizontal_rule,
    insertionText: '\n---\n\n',
  ),
];

class SlashCommandMenu extends StatelessWidget {
  final Function(SlashCommandItem item) onSelect;
  final VoidCallback onDismiss;

  const SlashCommandMenu({
    super.key,
    required this.onSelect,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 280,
        constraints: const BoxConstraints(maxHeight: 320),
        decoration: BoxDecoration(
          color: SpinelTheme.darkCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: SpinelTheme.rubyPrimary.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: SpinelTheme.borderColor)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SLASH COMMANDS',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: SpinelTheme.rubyBright,
                    ),
                  ),
                  InkWell(
                    onTap: onDismiss,
                    child: const Icon(Icons.close, size: 14, color: SpinelTheme.slateText),
                  ),
                ],
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: kSlashCommands.length,
                itemBuilder: (ctx, idx) {
                  final item = kSlashCommands[idx];
                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    leading: Icon(item.icon, size: 16, color: SpinelTheme.rubyBright),
                    title: Text(item.title, style: const TextStyle(color: SpinelTheme.brightText, fontSize: 12.5, fontWeight: FontWeight.w600)),
                    subtitle: Text(item.subtitle, style: const TextStyle(color: SpinelTheme.slateText, fontSize: 10.5)),
                    onTap: () => onSelect(item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
