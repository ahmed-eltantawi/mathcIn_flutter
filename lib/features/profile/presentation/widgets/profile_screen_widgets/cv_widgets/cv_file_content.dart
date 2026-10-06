import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/cv_widgets/cv_status_badge.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CvFileContent extends StatelessWidget {
  const CvFileContent({
    required this.fileName,
    this.status,
    this.updatedText,
    this.onView,
    this.onReplace,
    super.key,
  });

  final String fileName;
  final String? status;
  final String? updatedText;

  final VoidCallback? onView;
  final VoidCallback? onReplace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final locale = S.of(context);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.picture_as_pdf_outlined,
                  size: 27.r,
                  color: colors.primary,
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    if (status != null || updatedText != null) ...[
                      SizedBox(height: 5.h),

                      Wrap(
                        spacing: 8.w,
                        runSpacing: 4.h,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (status != null && status!.trim().isNotEmpty)
                            CvStatusBadge(status: status!),

                          if (updatedText != null &&
                              updatedText!.trim().isNotEmpty)
                            Text(
                              updatedText!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 14.h),

        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onView,
                child: Text(locale.viewCv),
              ),
            ),

            SizedBox(width: 10.w),

            Expanded(
              child: OutlinedButton(
                onPressed: onReplace,
                child: Text(locale.replaceCv),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
