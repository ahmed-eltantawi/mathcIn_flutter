import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JobFilterChip extends StatelessWidget {
  const JobFilterChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? context.colors.primary : context.colors.surface,
      borderRadius: BorderRadius.circular(24.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.r),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: isSelected
                  ? context.colors.primary
                  : context.theme.dividerColor,
            ),
          ),
          child: Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: isSelected
                  ? context.colors.onPrimary
                  : context.colors.onSurface.withValues(alpha: 0.65),
            ),
          ),
        ),
      ),
    );
  }
}
