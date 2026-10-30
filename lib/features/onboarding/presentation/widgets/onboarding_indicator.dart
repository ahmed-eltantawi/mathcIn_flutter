import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingIndicator extends StatelessWidget {
  const OnboardingIndicator({
    super.key,
    required this.currentPage,
    this.itemCount = 3,
  });

  final int currentPage;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(itemCount, (index) {
        final bool isSelected = currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.symmetric(horizontal: 3.w),
          width: isSelected ? 20.w : 6.w,
          height: 6.w,
          decoration: BoxDecoration(
            color: isSelected
                ? colors.primary
                : colors.outline.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(9999.r),
          ),
        );
      }),
    );
  }
}
