import 'package:flutter/material.dart';
import 'package:app/models/note_document.dart';
import 'package:app/theme/spinel_theme.dart';

class FrontmatterDialog extends StatefulWidget {
  final NoteDocument document;
  final VoidCallback onSaved;

  const FrontmatterDialog({
    super.key,
    required this.document,
    required this.onSaved,
  });

  static Future<void> show(BuildContext context, NoteDocument document, VoidCallback onSaved) {
    return showDialog(
      context: context,
      builder: (ctx) => FrontmatterDialog(document: document, onSaved: onSaved),
    );
  }

  @override
  State<FrontmatterDialog> createState() => _FrontmatterDialogState();
}

class _FrontmatterItem {
  TextEditingController keyController;
  TextEditingController valController;

  _FrontmatterItem(String k, dynamic v)
      : keyController = TextEditingController(text: k),
        valController = TextEditingController(
          text: v is List ? v.join(', ') : v.toString(),
        );

  void dispose() {
    keyController.dispose();
    valController.dispose();
  }
}

class _FrontmatterDialogState extends State<FrontmatterDialog> {
  final List<_FrontmatterItem> _items = [];

  @override
  void initState() {
    super.initState();
    widget.document.frontmatter.forEach((k, v) {
      _items.add(_FrontmatterItem(k, v));
    });
  }

  @override
  void dispose() {
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _addProperty() {
    setState(() {
      _items.add(_FrontmatterItem('', ''));
    });
  }

  void _save() {
    final newMap = <String, dynamic>{};
    for (final item in _items) {
      final k = item.keyController.text.trim();
      final v = item.valController.text.trim();
      if (k.isNotEmpty) {
        if (v.contains(',')) {
          newMap[k] = v.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
        } else {
          newMap[k] = v;
        }
      }
    }
    widget.document.frontmatter = newMap;
    widget.document.isModified = true;
    widget.onSaved();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: SpinelTheme.darkCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: SpinelTheme.borderColor),
      ),
      child: Container(
        width: 520,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.tune, size: 20, color: SpinelTheme.rubyPrimary),
                    SizedBox(width: 8),
                    Text(
                      'Edit Frontmatter Metadata',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: SpinelTheme.brightText,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: SpinelTheme.slateText),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: SpinelTheme.borderColor),
            const SizedBox(height: 12),
            if (_items.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                alignment: Alignment.center,
                child: const Text(
                  'No frontmatter properties defined.\nClick "+ Add Property" to add custom metadata.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: SpinelTheme.slateText, fontSize: 13),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, idx) {
                    final item = _items[idx];
                    return Row(
                      children: [
                        // Left-justified Key
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: item.keyController,
                            style: const TextStyle(fontSize: 13, color: SpinelTheme.brightText),
                            decoration: InputDecoration(
                              hintText: 'Property (e.g. tags)',
                              hintStyle: const TextStyle(color: SpinelTheme.slateText, fontSize: 12),
                              isDense: true,
                              filled: true,
                              fillColor: SpinelTheme.darkInput,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(color: SpinelTheme.borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(color: SpinelTheme.borderColor),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Right-justified Value
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: item.valController,
                            style: const TextStyle(fontSize: 13, color: SpinelTheme.brightText),
                            decoration: InputDecoration(
                              hintText: 'Value (e.g. sre, gemini)',
                              hintStyle: const TextStyle(color: SpinelTheme.slateText, fontSize: 12),
                              isDense: true,
                              filled: true,
                              fillColor: SpinelTheme.darkInput,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(color: SpinelTheme.borderColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                                borderSide: const BorderSide(color: SpinelTheme.borderColor),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                          tooltip: 'Remove',
                          onPressed: () {
                            setState(() {
                              _items.removeAt(idx);
                            });
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 16, color: SpinelTheme.rubyBright),
                  label: const Text('Add Property', style: TextStyle(color: SpinelTheme.rubyBright)),
                  onPressed: _addProperty,
                ),
                Row(
                  children: [
                    TextButton(
                      child: const Text('Cancel', style: TextStyle(color: SpinelTheme.slateText)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SpinelTheme.rubyPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: _save,
                      child: const Text('Apply Changes', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
