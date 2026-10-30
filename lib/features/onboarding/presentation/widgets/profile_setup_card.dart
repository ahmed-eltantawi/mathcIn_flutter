import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/features/onboarding/presentation/widgets/onboarding_action_button.dart';

class ProfileSetupCard extends StatelessWidget {
  const ProfileSetupCard({
    super.key,
    required this.onStart,
    required this.onNotNow,
  });

  final VoidCallback onStart;
  final VoidCallback onNotNow;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;
    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.4),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.setupCareerProfile,
            style: textTheme.headlineSmall?.copyWith(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
              letterSpacing: -0.6,
            ),
          ),
          SizedBox(height: 12.h),
          _buildBullet(
            context,
            dotColor: colors.secondary,
            text: l10n.onboardingBullet1,
          ),
          SizedBox(height: 10.h),
          _buildBullet(
            context,
            dotColor: colors.primary,
            text: l10n.onboardingBullet2,
          ),
          SizedBox(height: 10.h),
          _buildBullet(
            context,
            dotColor: colors.tertiary,
            text: l10n.onboardingBullet3,
          ),
          SizedBox(height: 16.h),
          OnboardingActionButton(text: l10n.start, onPressed: onStart),
          SizedBox(height: 8.h),
          Center(
            child: TextButton(
              onPressed: onNotNow,
              style: TextButton.styleFrom(
                minimumSize: Size(56.w, 36.h),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              ),
              child: Text(
                l10n.notNow,
                style: textTheme.labelLarge?.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: colors.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(
    BuildContext context, {
    required Color dotColor,
    required String text,
  }) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Row(
      children: [
        Container(
          width: 6.w,
          height: 6.w,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
