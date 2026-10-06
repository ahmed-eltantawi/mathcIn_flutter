import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CvStatusBadge extends StatelessWidget {
  const CvStatusBadge({required this.status, super.key});

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = _statusData(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
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

  ({String label, Color color}) _statusData(BuildContext context) {
    final locale = S.of(context);
    final colors = Theme.of(context).colorScheme;

    return switch (status.toLowerCase()) {
      'uploaded' => (label: locale.uploaded, color: colors.primary),
      'analyzing' => (label: locale.analyzing, color: AppColors.amber),
      'analyzed' => (label: locale.analyzed, color: AppColors.forestGreen),
      'failed' => (label: locale.failed, color: colors.error),
      _ => (label: status, color: colors.onSurfaceVariant),
    };
  }
}
