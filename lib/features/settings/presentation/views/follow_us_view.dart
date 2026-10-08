import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/extensions/snack_bar_extensions.dart';
import 'package:MatchIn/core/widgets/custom_app_bar.dart';
import 'package:MatchIn/features/settings/presentation/widgets/social_media_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FollowUsView extends StatelessWidget {
  const FollowUsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = context.theme;
    final l10n = context.l10n;

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.followUs,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(18.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.primary.withValues(alpha: 0.1),
                      colors.primary.withValues(alpha: 0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.15),
                  ),
                ),
                child: Text(
                  l10n.followUsDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              SocialMediaCard(
                name: 'LinkedIn',
                handle: '@skillmatch-app',
                icon: Icons.business_center_rounded,
                brandColor: const Color(0xFF0A66C2),
                onTap: () {
                  context.showInfoSnackBar('LinkedIn: @skillmatch-app');
                },
              ),

              SocialMediaCard(
                name: 'X (Twitter)',
                handle: '@SkillMatchApp',
                icon: Icons.tag_rounded,
                brandColor: colors.onSurface,
                onTap: () {
                  context.showInfoSnackBar('X: @SkillMatchApp');
                },
              ),

              SocialMediaCard(
                name: 'Instagram',
                handle: '@skillmatch.official',
                icon: Icons.camera_alt_outlined,
                brandColor: const Color(0xFFE4405F),
                onTap: () {
                  context.showInfoSnackBar('Instagram: @skillmatch.official');
                },
              ),

              SocialMediaCard(
                name: 'Facebook',
                handle: 'SkillMatch Community',
                icon: Icons.facebook_rounded,
                brandColor: const Color(0xFF1877F2),
                onTap: () {
                  context.showInfoSnackBar('Facebook: SkillMatch Community');
                },
              ),

              SocialMediaCard(
                name: 'YouTube',
                handle: '@SkillMatchCareers',
                icon: Icons.smart_display_outlined,
                brandColor: const Color(0xFFFF0000),
                onTap: () {
                  context.showInfoSnackBar('YouTube: @SkillMatchCareers');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
