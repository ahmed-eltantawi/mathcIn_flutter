import 'package:MatchIn/core/extensions/context_extensions.dart';
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
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: context.colors.primary,
              letterSpacing: -0.45,
              height: 24 / 18,
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
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: context.colors.secondary,
                  height: 20 / 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
