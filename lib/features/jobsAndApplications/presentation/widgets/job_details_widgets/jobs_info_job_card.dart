import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JobsInfoJobCard extends StatelessWidget {
  const JobsInfoJobCard({
    super.key,
    required this.label,
    this.icon,
    this.showBorder = false,
  });

  final String label;
  final IconData? icon;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 16.sp,
            color: context.colors.onSurface.withValues(alpha: 0.55),
          ),
          SizedBox(width: 4.w),
        ],

        Text(
          label,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );

    if (!showBorder) {
      return content;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        border: Border.all(color: context.theme.dividerColor),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: content,
    );
  }
}
