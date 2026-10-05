import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

class ProfileOverviewCompletionStatus extends StatelessWidget {
  const ProfileOverviewCompletionStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Text(
          'Career profile',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        Gap(8.w),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8.r,
              height: 8.r,
              decoration: const BoxDecoration(
                color: Color(0xFFE46A6A),
                shape: BoxShape.circle,
              ),
            ),
            Gap(6.w),
            Text(
              'Almost complete',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFE46A6A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
