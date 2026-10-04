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
  const ProfileOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: context.theme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileOverviewAvatar(),
              SizedBox(width: 12),
              Expanded(
                child: ProfileOverviewIdentity(
                  name: '',
                  jobTitle: '',
                  location: '',
                  experienceLevel: '',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const ProfileOverviewSummary(),
          const SizedBox(height: 16),
          const ProfileOverviewEditButton(),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),
          ProfileOverviewSocialLinks(
            githubLabel: '',
            linkedinLabel: '',
            onGithubPressed: () {},
            onLinkedinPressed: () {},
          ),
          const SizedBox(height: 14),
          const ProfileOverviewCompletionStatus(),
        ],
      ),
    );
  }
}
