import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/extensions/date_time_extensions.dart';
import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/application_entity.dart';
import 'package:MatchIn/features/saved/presentation/models/applied_job_ui_model.dart' as ui_model;

class AppliedJobCard extends StatelessWidget {
  const AppliedJobCard({
    super.key,
    this.application,
    this.applicationEntity,
    this.onViewApplicationTap,
    this.onCardTap,
  });

  final ui_model.AppliedJobUiModel? application;
  final ApplicationEntity? applicationEntity;
  final VoidCallback? onViewApplicationTap;
  final VoidCallback? onCardTap;

  @override
  Widget build(BuildContext context) {
    final status = _resolveStatus();
    final isInterview = status == ApplicationStatus.interview;

    final title = applicationEntity?.job?.title ?? application?.title ?? 'Job Position';
    final company = applicationEntity?.job?.companyName ?? application?.company ?? 'Company';
    final companyInitials = _getInitials(company);
    final appliedTime = applicationEntity?.appliedAt != null
        ? applicationEntity!.appliedAt!.timeAgo(context)
        : (application?.appliedTime ?? 'Recently');
    final footerStatus = applicationEntity != null
        ? '${S.of(context).applicationStatus}: ${_formatStatus(status, context)}'
        : (application?.footerStatus ?? 'Application submitted');

    final tags = applicationEntity != null
        ? [
            if (applicationEntity!.job?.location != null && applicationEntity!.job!.location.isNotEmpty)
              applicationEntity!.job!.location,
            if (applicationEntity!.job?.workMode != null && applicationEntity!.job!.workMode.isNotEmpty)
              applicationEntity!.job!.workMode,
            if (applicationEntity!.job?.employmentType != null && applicationEntity!.job!.employmentType.isNotEmpty)
              applicationEntity!.job!.employmentType,
          ]
        : (application?.tags ?? []);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: isInterview
              ? AppColors.amber.withValues(alpha: 0.35)
              : context.theme.dividerColor,
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isInterview ? null : context.colors.surface,
          gradient: isInterview
              ? LinearGradient(
                  colors: [
                    context.colors.surface,
                    AppColors.amber.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
        ),
        child: InkWell(
          onTap: onCardTap ?? onViewApplicationTap,
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: Logo + Title/Company + Status Chip
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44.r,
                      height: 44.r,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: application?.logoBgColor ??
                            context.semanticColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: (application?.logoTextColor ??
                                  context.semanticColors.success)
                              .withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        companyInitials,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: application?.logoTextColor ??
                              context.semanticColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            company,
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.colors.onSurface.withValues(
                                alpha: 0.65,
                              ),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    _buildStatusChip(context, status),
                  ],
                ),

                SizedBox(height: 12.h),

                // Metadata Tags + Applied Time
                Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ...tags.map((tag) => _buildTag(context, tag)),
                    Padding(
                      padding: EdgeInsets.only(left: 4.w),
                      child: Text(
                        appliedTime,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurface.withValues(
                            alpha: 0.55,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                if (application?.highlightNote != null) ...[
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.08),
                      border: Border.all(
                        color: AppColors.amber.withValues(alpha: 0.25),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16.sp,
                          color: AppColors.amber,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            application!.highlightNote!,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: AppColors.amber,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 12.h),
                Divider(height: 1.h, color: context.theme.dividerColor),
                SizedBox(height: 10.h),

                // Bottom Action Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        footerStatus,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    InkWell(
                      onTap: onViewApplicationTap,
                      borderRadius: BorderRadius.circular(8.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 4.h,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              S.of(context).viewApplication,
                              style: context.textTheme.labelLarge?.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 2.w),
                            Icon(
                              Icons.chevron_right,
                              size: 18.sp,
                              color: context.colors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ApplicationStatus _resolveStatus() {
    if (applicationEntity != null) {
      return applicationEntity!.status;
    }
    if (application != null) {
      switch (application!.status) {
        case ui_model.ApplicationStatus.applied:
          return ApplicationStatus.applied;
        case ui_model.ApplicationStatus.inReview:
          return ApplicationStatus.inReview;
        case ui_model.ApplicationStatus.interview:
          return ApplicationStatus.interview;
      }
    }
    return ApplicationStatus.applied;
  }

  String _getInitials(String company) {
    final words = company.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      final w = words.first;
      return w.substring(0, w.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  String _formatStatus(ApplicationStatus status, BuildContext context) {
    final s = S.of(context);
    switch (status) {
      case ApplicationStatus.applied:
        return s.applied;
      case ApplicationStatus.inReview:
        return s.inReview;
      case ApplicationStatus.interview:
        return s.interview;
      case ApplicationStatus.offer:
        return s.offer;
      case ApplicationStatus.rejected:
        return s.failed;
      case ApplicationStatus.withdrawn:
        return s.withdrawApplication;
      case ApplicationStatus.unknown:
        return s.applied;
    }
  }

  Widget _buildStatusChip(BuildContext context, ApplicationStatus status) {
    Color textColor;
    Color bgColor;
    Color borderColor;
    final label = _formatStatus(status, context);

    switch (status) {
      case ApplicationStatus.applied:
        textColor = context.colors.primary;
        bgColor = context.colors.primary.withValues(alpha: 0.10);
        borderColor = context.colors.primary.withValues(alpha: 0.20);
        break;
      case ApplicationStatus.inReview:
        textColor = context.colors.secondary;
        bgColor = context.colors.secondary.withValues(alpha: 0.10);
        borderColor = context.colors.secondary.withValues(alpha: 0.20);
        break;
      case ApplicationStatus.interview:
        textColor = AppColors.amber;
        bgColor = AppColors.amber.withValues(alpha: 0.12);
        borderColor = AppColors.amber.withValues(alpha: 0.30);
        break;
      case ApplicationStatus.offer:
        textColor = context.semanticColors.success;
        bgColor = context.semanticColors.success.withValues(alpha: 0.12);
        borderColor = context.semanticColors.success.withValues(alpha: 0.30);
        break;
      case ApplicationStatus.rejected:
        textColor = context.colors.error;
        bgColor = context.colors.error.withValues(alpha: 0.10);
        borderColor = context.colors.error.withValues(alpha: 0.20);
        break;
      case ApplicationStatus.withdrawn:
        textColor = context.colors.onSurface.withValues(alpha: 0.55);
        bgColor = context.colors.onSurface.withValues(alpha: 0.08);
        borderColor = context.colors.onSurface.withValues(alpha: 0.20);
        break;
      case ApplicationStatus.unknown:
        textColor = context.colors.primary;
        bgColor = context.colors.primary.withValues(alpha: 0.10);
        borderColor = context.colors.primary.withValues(alpha: 0.20);
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 6.r,
            height: 6.r,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: context.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(BuildContext context, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border.all(
          color: context.theme.dividerColor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: context.textTheme.labelSmall?.copyWith(
          color: context.colors.onSurface.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
