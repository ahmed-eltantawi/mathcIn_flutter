import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/utils/app_assets.dart';

class OpportunityHeroWidget extends StatelessWidget {
  const OpportunityHeroWidget({
    super.key,
    this.imagePath = Assets.imagesOnboarding1,
  });

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Container(
        width: 326.w,
        height: 326.w,
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: colors.outline.withValues(alpha: 0.6),
            width: 1.w,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            color: colors.surfaceContainerHighest,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallback(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.surface,
            colors.surfaceContainerHighest.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90.w,
              height: 90.w,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.08),
                    blurRadius: 16.r,
                    offset: Offset(0, 6.h),
                  ),
                ],
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 42.r,
                color: colors.primary,
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: colors.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: colors.secondary.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                'AI Career Matcher',
                style: textTheme.labelMedium?.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: colors.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
