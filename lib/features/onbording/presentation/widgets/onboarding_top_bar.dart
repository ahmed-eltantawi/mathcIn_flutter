import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/utils/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingTopBar extends StatelessWidget {
  const OnboardingTopBar({
    super.key,
    required this.currentPage,
    required this.onSkip,
    this.onNotNow,
    this.totalSteps = 3,
  });

  final int currentPage;
  final VoidCallback onSkip;
  final VoidCallback? onNotNow;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = currentPage >= totalSteps - 1;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand Wordmark
          Text(
            'Matchin',
            style: AppTextStyles.heading18Bold(
              isArabic: false,
              color: context.colors.primary,
            ),
          ),

          // Trailing Action: Skip on earlier pages, Not Now on last page
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: isLastPage ? (onNotNow ?? onSkip) : onSkip,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size(40.w, 24.h),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                isLastPage ? context.l10n.notNow : context.l10n.skip,
                style: AppTextStyles.body14SemiBold(
                  isArabic: false,
                  color: context.colors.secondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
