import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/utils/app_text_styles.dart';
import 'package:MatchIn/features/onbording/presentation/widgets/onboarding_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingNarrativeSection extends StatelessWidget {
  const OnboardingNarrativeSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onNext,
    this.buttonText = 'Continue',
    this.titleFontSize,
  });

  final String title;
  final String subtitle;
  final VoidCallback onNext;
  final String buttonText;
  final double? titleFontSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: AppTextStyles.heading24Bold(
            isArabic: false,
            color: context.colors.onSurface,
          ).copyWith(
            fontSize: titleFontSize ?? 24.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          subtitle,
          style: AppTextStyles.body14Regular(
            isArabic: false,
            color: context.colors.onSurfaceVariant,
          ).copyWith(
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 24.h),
        OnboardingActionButton(text: buttonText, onPressed: onNext),
      ],
    );
  }
}
