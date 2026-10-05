import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileOverviewIdentity extends StatelessWidget {
  const ProfileOverviewIdentity({
    required this.name,
    required this.jobTitle,
    required this.location,
    required this.experienceLevel,
    super.key,
  });

  final String name;
  final String jobTitle;
  final String location;
  final String experienceLevel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 2.h),
        Text(jobTitle, style: theme.textTheme.bodyMedium),
        SizedBox(height: 5.h),
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 15.r,
              color: colors.onSurfaceVariant,
            ),
            SizedBox(width: 2.w),
            Flexible(
              child: Text(
                location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text(experienceLevel, style: theme.textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }
}
