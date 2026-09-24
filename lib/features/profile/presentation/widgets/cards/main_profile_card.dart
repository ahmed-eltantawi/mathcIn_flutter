import 'package:MatchIn/core/utils/app_constants.dart';
import 'package:MatchIn/features/profile/presentation/widgets/shared/profile_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainProfileCard extends StatelessWidget {
  const MainProfileCard({
    super.key,
    required this.name,
    required this.jobTitle,
    required this.location,
  });

  final String name;
  final String jobTitle;
  final String location;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ProfileSectionCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 35.r,
            backgroundImage: const NetworkImage(AppConstants.defaultAvatarUrl),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  jobTitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16.sp,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      location,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}