import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditProfileDropdown extends StatelessWidget {
  const EditProfileDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    super.key,
    this.hintText,
  });

  final String label;
  final String? value;
  final Map<String, String> items;
  final ValueChanged<String?> onChanged;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hasValue = value != null && items.containsKey(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          initialValue: hasValue ? value : null,
          isExpanded: true,
          hint: hintText == null ? null : Text(hintText!),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 17.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
          ),
          items: items.entries
              .map(
                (entry) => DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text(entry.value),
                ),
              )
              .toList(),
          onChanged: items.isEmpty ? null : onChanged,
        ),
      ],
    );
  }
}
