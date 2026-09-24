import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReviewCvCard extends StatelessWidget {
  const ReviewCvCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(
              Icons.description_outlined,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ahmed_Mohamed_CV.pdf',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  'PDF • 1.4 MB',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 9.w,
              vertical: 4.h,
            ),
            decoration: BoxDecoration(
              color: AppColors.forestGreen.withValues(
                alpha: 0.10,
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '● ${s.ready}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.forestGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
