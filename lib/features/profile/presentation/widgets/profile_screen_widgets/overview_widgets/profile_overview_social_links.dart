import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/overview_widgets/profile_overview_link_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileOverviewSocialLinks extends StatelessWidget {
  const ProfileOverviewSocialLinks({
    required this.githubLabel,
    required this.linkedinLabel,
    required this.onGithubPressed,
    required this.onLinkedinPressed,
    super.key,
  });

  final String githubLabel;
  final String linkedinLabel;
  final VoidCallback onGithubPressed;
  final VoidCallback onLinkedinPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 8.h,
      children: [
        ProfileOverviewLinkChip(
          icon: Icons.code_rounded,
          label: githubLabel,
          onPressed: onGithubPressed,
        ),
        ProfileOverviewLinkChip(
          icon: Icons.link_rounded,
          label: linkedinLabel,
          onPressed: onLinkedinPressed,
        ),
      ],
    );
  }
}
