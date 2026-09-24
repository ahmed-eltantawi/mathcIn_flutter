import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/utils/app_assets.dart';

class JobMatchHeroWidget extends StatelessWidget {
  const JobMatchHeroWidget({
    super.key,
    this.imagePath = Assets.imagesOnboarding2,
  });

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Center(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Outer Visual Container
            Container(
              width: 356.w,
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.6),
                  width: 1.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.05),
                    blurRadius: 20.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  height: 240.h,
                  width: double.infinity,
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

            SizedBox(height: 10.h),

            // Job Match Information Card
            Container(
              width: 340.w,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: colors.outline),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2.r,
                    offset: Offset(0, 1.h),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              color: colors.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Flutter Developer Intern',
                            style: textTheme.titleMedium?.copyWith(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: colors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F7A5A).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(9999.r),
                          border: Border.all(
                            color: const Color(0xFF4F7A5A)
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          'Strong match',
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF4F7A5A),
                          ),
                        ),
                      ),
                    ],
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: Divider(
                      height: 1.h,
                      color: colors.outline.withValues(alpha: 0.3),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TechNova • Cairo • Hybrid',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: colors.tertiary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4.r),
                          border: Border.all(
                            color: colors.tertiary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          'Top',
                          style: textTheme.labelSmall?.copyWith(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: colors.tertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.surface,
            colors.surfaceContainerHighest.withValues(alpha: 0.4),
          ],
        ),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.06),
                    blurRadius: 10.r,
                  ),
                ],
              ),
              child: Icon(
                Icons.description_outlined,
                size: 32.r,
                color: colors.primary,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Icon(
                Icons.compare_arrows_rounded,
                size: 28.r,
                color: colors.secondary,
              ),
            ),
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.06),
                    blurRadius: 10.r,
                  ),
                ],
              ),
              child: Icon(
                Icons.work_outline_rounded,
                size: 32.r,
                color: colors.tertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
