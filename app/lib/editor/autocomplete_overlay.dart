import 'package:flutter/material.dart';
import 'package:app/theme/spinel_theme.dart';

class AutocompleteOverlay extends StatelessWidget {
  final String title;
  final List<String> suggestions;
  final Function(String selected) onSelected;
  final VoidCallback onDismiss;

  const AutocompleteOverlay({
    super.key,
    required this.title,
    required this.suggestions,
    required this.onSelected,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: Container(
        width: 240,
        constraints: const BoxConstraints(maxHeight: 220),
        decoration: BoxDecoration(
          color: SpinelTheme.darkCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: SpinelTheme.rubyPrimary.withOpacity(0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: SpinelTheme.borderColor)),
              ),
              child: Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: SpinelTheme.rubyBright,
                ),
              ),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 4),
                itemCount: suggestions.length,
                itemBuilder: (ctx, idx) {
                  final item = suggestions[idx];
                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    leading: const Icon(Icons.link, size: 14, color: Colors.lightBlueAccent),
                    title: Text(item, style: const TextStyle(color: SpinelTheme.brightText, fontSize: 12)),
                    onTap: () => onSelected(item),
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
