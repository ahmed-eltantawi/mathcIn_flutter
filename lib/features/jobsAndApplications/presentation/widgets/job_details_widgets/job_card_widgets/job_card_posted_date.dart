import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JobCardPostedDate extends StatelessWidget {
  const JobCardPostedDate({
    super.key,
    required this.postedDate,
  });

  final String postedDate;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.schedule_rounded,
          size: 16.sp,
          color: context.colors.onSurface.withValues(
            alpha: 0.55,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          postedDate,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colors.onSurface.withValues(
              alpha: 0.6,
            ),
          ),
        ),
      ],
    );
  }
}
