import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GenderSelector extends StatelessWidget {
  const GenderSelector({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale.gender,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _buildOption(
                context: context,
                label: locale.male,
                machineValue: 'male',
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildOption(
                context: context,
                label: locale.female,
                machineValue: 'female',
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _buildOption(
                context: context,
                label: locale.preferNotToSay,
                machineValue: 'prefer_not_to_say',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required String label,
    required String machineValue,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selected = value == machineValue;

    return InkWell(
      onTap: () => onChanged(machineValue),
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        constraints: BoxConstraints(minHeight: 50.h),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 10.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withValues(alpha: 0.08)
              : colors.surface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: selected ? colors.primary : theme.dividerColor,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: selected ? colors.primary : colors.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
