import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum CvFileStatus {
  empty,
  uploaded,
  analyzing,
  analyzed,
  failed,
}

class CvFileCard extends StatelessWidget {
  const CvFileCard({
    super.key,
    this.status = CvFileStatus.empty,
    this.fileName,
    this.updatedText,
    this.qualityText,
    this.onUpload,
    this.onView,
    this.onReplace,
    this.onEdit,
  });

  final CvFileStatus status;

  final String? fileName;
  final String? updatedText;
  final String? qualityText;

  final VoidCallback? onUpload;
  final VoidCallback? onView;
  final VoidCallback? onReplace;
  final VoidCallback? onEdit;

  bool get _hasFile => status != CvFileStatus.empty;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CvHeader(
              hasFile: _hasFile,
              qualityText: qualityText,
              onEdit: onEdit ?? onReplace,
            ),
            SizedBox(height: 14.h),
            const Divider(height: 1),
            SizedBox(height: 16.h),
            if (_hasFile)
              _CvFileContent(
                status: status,
                fileName: fileName ?? '',
                updatedText: updatedText,
                onView: onView,
                onReplace: onReplace,
              )
            else
              _EmptyCvContent(onUpload: onUpload),
          ],
        ),
      ),
    );
  }
}

class _CvHeader extends StatelessWidget {
  const _CvHeader({
    required this.hasFile,
    required this.qualityText,
    required this.onEdit,
  });

  final bool hasFile;
  final String? qualityText;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    return Row(
      children: [
        Icon(
          Icons.description_outlined,
          color: theme.colorScheme.primary,
          size: 27.sp,
        ),
        SizedBox(width: 9.w),
        Expanded(
          child: Text(
            s.cv,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        if (hasFile && qualityText != null) ...[
          Container(
            width: 7.r,
            height: 7.r,
            decoration: const BoxDecoration(
              color: AppColors.amber,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            qualityText!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.amber,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4.w),
        ],
        if (hasFile)
          IconButton(
            onPressed: onEdit ?? () {},
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.edit_outlined,
              color: theme.colorScheme.onSurface.withValues(
                alpha: 0.6,
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyCvContent extends StatelessWidget {
  const _EmptyCvContent({required this.onUpload});

  final VoidCallback? onUpload;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    return Column(
      children: [
        Container(
          width: 64.r,
          height: 64.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color:
                theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Icon(
            Icons.upload_file_outlined,
            color: theme.colorScheme.primary,
            size: 32.sp,
          ),
        ),
        SizedBox(height: 14.h),
        Text(
          s.uploadYourCv,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          s.cvUploadRequirements,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(
              alpha: 0.65,
            ),
          ),
        ),
        SizedBox(height: 18.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onUpload ?? () {},
            icon: const Icon(Icons.upload_outlined),
            label: Text(s.chooseFile),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 14.w,
            vertical: 14.h,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Icon(
                Icons.insert_drive_file_outlined,
                color: theme.colorScheme.onSurface
                    .withValues(alpha: 0.55),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  s.noFileSelected,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.65),
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

class _CvFileContent extends StatelessWidget {
  const _CvFileContent({
    required this.status,
    required this.fileName,
    required this.updatedText,
    required this.onView,
    required this.onReplace,
  });

  final CvFileStatus status;
  final String fileName;
  final String? updatedText;
  final VoidCallback? onView;
  final VoidCallback? onReplace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.picture_as_pdf_outlined,
                  color: theme.colorScheme.primary,
                  size: 27.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 4.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 4.h,
                      crossAxisAlignment:
                          WrapCrossAlignment.center,
                      children: [
                        _StatusBadge(status: status),
                        if (updatedText != null)
                          Text(
                            updatedText!,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(
                                  color: theme
                                      .colorScheme
                                      .onSurface
                                      .withValues(
                                        alpha: 0.6,
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
        SizedBox(height: 14.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onView ?? () {},
                child: Text(s.viewCv),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: OutlinedButton(
                onPressed: onReplace ?? () {},
                child: Text(s.replaceCv),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final CvFileStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = _getData(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 3.h,
      ),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        data.label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: data.color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  _CvStatusData _getData(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    switch (status) {
      case CvFileStatus.empty:
        return _CvStatusData(
          label: '',
          color: theme.colorScheme.onSurface,
        );

      case CvFileStatus.uploaded:
        return _CvStatusData(
          label: s.uploaded,
          color: theme.colorScheme.primary,
        );

      case CvFileStatus.analyzing:
        return _CvStatusData(
          label: s.analyzing,
          color: AppColors.amber,
        );

      case CvFileStatus.analyzed:
        return _CvStatusData(
          label: s.analyzed,
          color: AppColors.forestGreen,
        );

      case CvFileStatus.failed:
        return _CvStatusData(
          label: s.failed,
          color: theme.colorScheme.error,
        );
    }
  }
}

class _CvStatusData {
  const _CvStatusData({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;
}
