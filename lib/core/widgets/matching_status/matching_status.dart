import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/widgets/matching_status/matching_status_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MatchingStatus extends StatelessWidget {
  const MatchingStatus({
    super.key,
    required this.percentage,
  });

  /// null = لسه مفيش نسبة تطابق متاحة (مثلاً المستخدم لسه مرفعش CV)
  final int? percentage;

  @override
  Widget build(BuildContext context) {
    if (percentage == null) {
      return const SizedBox.shrink();
    }

    final type = MatchingStatusType.fromPercentage(
      percentage!,
    );
    final data = _getStatusData(context, type, percentage!);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 5.h,
      ),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.r,
            height: 7.r,
            decoration: BoxDecoration(
              color: data.color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            data.label,
            style: context.textTheme.labelMedium?.copyWith(
              color: data.color,
            ),
          ),
        ],
      ),
    );
  }

  _MatchingStatusData _getStatusData(
    BuildContext context,
    MatchingStatusType type,
    int percentage,
  ) {
    final colors = context.colors;

    switch (type) {
      case MatchingStatusType.excellent:
        return _MatchingStatusData(
          label: '$percentage% ${context.l10n.strongMatch}',
          color: colors.primary,
        );

      case MatchingStatusType.good:
        return _MatchingStatusData(
          label: '$percentage% ${context.l10n.goodMatch}',
          color: colors.tertiary,
        );

      case MatchingStatusType.fair:
        return _MatchingStatusData(
          label: '$percentage% ${context.l10n.fairMatch}',
          color: colors.secondary,
        );

      case MatchingStatusType.poor:
        return _MatchingStatusData(
          label: '$percentage% ${context.l10n.match}',
          color: colors.error,
        );
    }
  }
}

class _MatchingStatusData {
  const _MatchingStatusData({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;
}
