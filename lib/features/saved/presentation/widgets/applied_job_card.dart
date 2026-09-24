import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/features/saved/presentation/models/applied_job_ui_model.dart';

class AppliedJobCard extends StatelessWidget {
  const AppliedJobCard({
    super.key,
    required this.application,
    this.onViewApplicationTap,
    this.onCardTap,
  });

  final AppliedJobUiModel application;
  final VoidCallback? onViewApplicationTap;
  final VoidCallback? onCardTap;

  @override
  Widget build(BuildContext context) {
    final isInterview = application.status == ApplicationStatus.interview;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: isInterview
              ? const Color(0xFFC88A26).withValues(alpha: 0.35)
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
                    const Color(0xFFC88A26).withValues(alpha: 0.05),
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
                        color: application.logoBgColor,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: application.logoTextColor.withValues(
                            alpha: 0.25,
                          ),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        application.companyInitials,
                        style: context.textTheme.titleMedium?.copyWith(
                          color: application.logoTextColor,
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
                            application.title,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            application.company,
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
                    _buildStatusChip(context, application.status),
                  ],
                ),

                SizedBox(height: 12.h),

                // Metadata Tags + Applied Time (Wrap ensures NO horizontal overflow)
                Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ...application.tags.map((tag) => _buildTag(context, tag)),
                    Padding(
                      padding: EdgeInsets.only(left: 4.w),
                      child: Text(
                        application.appliedTime,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurface.withValues(
                            alpha: 0.55,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Highlight Note (e.g. Interview scheduled)
                if (application.highlightNote != null) ...[
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC88A26).withValues(alpha: 0.08),
                      border: Border.all(
                        color: const Color(0xFFC88A26).withValues(alpha: 0.25),
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
                          color: const Color(0xFFC88A26),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            application.highlightNote!,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF8F610E),
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

                // Bottom Action Row: footer status + View application
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        application.footerStatus,
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
                              'View Application',
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

  Widget _buildStatusChip(BuildContext context, ApplicationStatus status) {
    Color textColor;
    Color bgColor;
    Color borderColor;
    String label;

    switch (status) {
      case ApplicationStatus.applied:
        textColor = context.colors.primary;
        bgColor = context.colors.primary.withValues(alpha: 0.10);
        borderColor = context.colors.primary.withValues(alpha: 0.20);
        label = 'Applied';
        break;
      case ApplicationStatus.inReview:
        textColor = context.colors.secondary;
        bgColor = context.colors.secondary.withValues(alpha: 0.10);
        borderColor = context.colors.secondary.withValues(alpha: 0.20);
        label = 'In Review';
        break;
      case ApplicationStatus.interview:
        textColor = const Color(0xFFC88A26);
        bgColor = const Color(0xFFC88A26).withValues(alpha: 0.12);
        borderColor = const Color(0xFFC88A26).withValues(alpha: 0.30);
        label = 'Interview';
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
