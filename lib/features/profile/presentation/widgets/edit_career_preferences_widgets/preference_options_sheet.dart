import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Bottom-sheet list picker for Career Preferences option fields.
///
/// Shows [options] machine values verbatim and completes with the
/// selected machine value (or null on dismiss). Unknown existing
/// backend values are included by callers so they keep displaying.
class PreferenceOptionsSheet extends StatelessWidget {
  const PreferenceOptionsSheet({
    required this.title,
    required this.options,
    required this.selected,
    super.key,
  });

  final String title;
  final List<String> options;
  final String? selected;

  static Future<String?> show(
    BuildContext context, {
    required String title,
    required List<String> options,
    String? selected,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      builder: (_) => PreferenceOptionsSheet(
        title: title,
        options: options,
        selected: selected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = option == selected;
                return ListTile(
                  title: Text(option),
                  trailing: isSelected
                      ? Icon(Icons.check, color: theme.colorScheme.primary)
                      : null,
                  onTap: () => Navigator.of(context).pop(option),
                );
              },
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}
