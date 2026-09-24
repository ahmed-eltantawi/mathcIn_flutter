import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubmittedStatusCard extends StatelessWidget {
  const SubmittedStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            _StatusRow(
              label: s.applicationStatus,
              value: s.applied,
              showDot: true,
            ),
            const Divider(height: 24),
            _StatusRow(
              icon: Icons.schedule_outlined,
              label: s.timeline,
              value: s.submittedJustNow,
            ),
            const Divider(height: 24),
            _StatusRow(
              icon: Icons.apartment_rounded,
              label: s.recruiterReview,
              value: s.withinThreeBusinessDays,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
    this.icon,
    this.showDot = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 20.sp,
            color: theme.colorScheme.onSurface.withValues(
              alpha: 0.6,
            ),
          ),
          SizedBox(width: 8.w),
        ],
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(
                alpha: 0.6,
              ),
            ),
          ),
        ),
        if (showDot)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 6.h,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(
                alpha: 0.08,
              ),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '● $value',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
