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
    this.disabledValues = const {},
  });

  final String label;
  final String? value;
  final Map<String, String> items;
  final ValueChanged<String?> onChanged;
  final String? hintText;

  /// Machine values that render but cannot be selected (e.g. an option
  /// whose backend value is not confirmed yet). Never submitted.
  final Set<String> disabledValues;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final currentValue = value?.trim();

    final availableItems = Map<String, String>.from(items);

    if (currentValue != null &&
        currentValue.isNotEmpty &&
        !availableItems.containsKey(currentValue)) {
      availableItems[currentValue] = currentValue;
    }

    final selectedValue =
        currentValue != null &&
            currentValue.isNotEmpty &&
            availableItems.containsKey(currentValue)
        ? currentValue
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),

        SizedBox(height: 8.h),

        DropdownButtonFormField<String>(
          key: ValueKey(selectedValue),
          initialValue: selectedValue,
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
          items: availableItems.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              enabled: !disabledValues.contains(entry.key),
              child: Text(entry.value, overflow: TextOverflow.ellipsis),
            );
          }).toList(),

          // No selection changes until actual options are available.
          onChanged: items.isEmpty ? null : onChanged,
        ),
      ],
    );
  }
}
