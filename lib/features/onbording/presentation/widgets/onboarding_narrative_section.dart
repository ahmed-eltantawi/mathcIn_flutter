import 'package:MatchIn/core/extensions/context_extensions.dart';
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
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: titleFontSize ?? 24.sp,
            fontWeight: FontWeight.w700,
            color: context.colors.onSurface,
            letterSpacing: -0.6,
            height: 30 / 24,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: context.colors.onSurfaceVariant,
            height: 26 / 16,
          ),
        ),
        SizedBox(height: 24.h),
        OnboardingActionButton(text: buttonText, onPressed: onNext),
      ],
    );
  }
}
