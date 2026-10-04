import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PreferenceChoiceChip extends StatelessWidget {
  const PreferenceChoiceChip({
    required this.label,
    required this.isSelected,
    required this.onPressed,
    this.showCheck = true,
    super.key,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;
  final bool showCheck;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(100.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? colors.primary : colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(
            color: isSelected ? colors.primary : theme.dividerColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected && showCheck) ...[
              Icon(Icons.check_rounded, size: 16.r, color: colors.onPrimary),
              SizedBox(width: 5.w),
            ],
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: isSelected ? colors.onPrimary : colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
