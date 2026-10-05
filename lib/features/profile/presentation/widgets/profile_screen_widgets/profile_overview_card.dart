import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/overview_widgets/profile_overview_avatar.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/overview_widgets/profile_overview_completion_status.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/overview_widgets/profile_overview_edit_button.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/overview_widgets/profile_overview_identity.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/overview_widgets/profile_overview_social_links.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/overview_widgets/profile_overview_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileOverviewCard extends StatelessWidget {
  const ProfileOverviewCard({
    required this.name,
    required this.jobTitle,
    required this.location,
    required this.summary,
    this.avatarUrl,
    this.githubUrl,
    this.linkedinUrl,
    super.key,
  });

  final String name;
  final String jobTitle;
  final String location;
  final String summary;

  final String? avatarUrl;
  final String? githubUrl;
  final String? linkedinUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: context.theme.dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileOverviewAvatar(imageUrl: avatarUrl),
              SizedBox(width: 12.w),
              Expanded(
                child: ProfileOverviewIdentity(
                  name: name,
                  jobTitle: jobTitle,
                  location: location,

                  // UI only for now.
                  experienceLevel: '',
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          ProfileOverviewSummary(summary: summary),

          SizedBox(height: 16.h),

          const ProfileOverviewEditButton(),

          SizedBox(height: 16.h),

          const Divider(height: 1),

          SizedBox(height: 14.h),

          ProfileOverviewSocialLinks(
            githubUrl: githubUrl,
            linkedinUrl: linkedinUrl,
          ),

          SizedBox(height: 14.h),

          // UI only until backend provides completion data.
          const ProfileOverviewCompletionStatus(),
        ],
      ),
    );
  }
}
