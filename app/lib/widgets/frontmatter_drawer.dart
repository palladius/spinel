import 'package:flutter/material.dart';
import 'package:app/models/note_document.dart';
import 'package:app/theme/spinel_theme.dart';

class FrontmatterDrawer extends StatelessWidget {
  final NoteDocument document;
  final VoidCallback onUpdated;

  const FrontmatterDrawer({
    super.key,
    required this.document,
    required this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: SpinelTheme.darkSidebar,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.label_outline, size: 18, color: SpinelTheme.rubyAccent),
              SizedBox(width: 8),
              Text(
                'Frontmatter Inspector',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: SpinelTheme.brightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: SpinelTheme.borderColor),
          const SizedBox(height: 8),
          Expanded(
            child: document.frontmatter.isEmpty
                ? const Center(
                    child: Text(
                      'No frontmatter metadata.\nAdd properties via ---\nYAML header.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: SpinelTheme.slateText, fontSize: 12),
                    ),
                  )
                : ListView(
                    children: document.frontmatter.entries.map((entry) {
                      return _propertyRow(entry.key, entry.value);
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _propertyRow(String key, dynamic value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: SpinelTheme.darkSurface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: SpinelTheme.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            key,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: SpinelTheme.rubyAccent,
            ),
          ),
          const SizedBox(height: 4),
          if (value is List)
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: value.map((tag) {
                return Chip(
                  label: Text(
                    tag.toString(),
                    style: const TextStyle(fontSize: 10, color: SpinelTheme.brightText),
                  ),
                  backgroundColor: SpinelTheme.darkCard,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: const BorderSide(color: SpinelTheme.borderColor),
                );
              }).toList(),
            )
          else
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 12, color: SpinelTheme.brightText),
            ),
        ],
      ),
    );
  }
}
