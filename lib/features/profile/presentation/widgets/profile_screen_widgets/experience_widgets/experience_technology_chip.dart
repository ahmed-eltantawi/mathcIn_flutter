import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExperienceTechnologyChip extends StatelessWidget {
  const ExperienceTechnologyChip({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: context.theme.dividerColor),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
