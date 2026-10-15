import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CvEmptyContent extends StatelessWidget {
  const CvEmptyContent({this.onUpload, super.key});

  final VoidCallback? onUpload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final locale = S.of(context);

    return Column(
      children: [
        Container(
          width: 64.r,
          height: 64.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Icon(
            Icons.upload_file_outlined,
            size: 32.r,
            color: colors.primary,
          ),
        ),

        SizedBox(height: 14.h),

        Text(
          locale.uploadYourCv,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),

        SizedBox(height: 5.h),

        Text(
          locale.cvUploadRequirements,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),

        SizedBox(height: 18.h),

        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onUpload,
            icon: Icon(Icons.upload_outlined, size: 20.r),
            label: Text(locale.chooseFile),
          ),
        ),

        SizedBox(height: 12.h),

        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.insert_drive_file_outlined,
                size: 21.r,
                color: colors.onSurfaceVariant,
              ),

              SizedBox(width: 10.w),

              Expanded(
                child: Text(
                  locale.noFileSelected,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
