import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum ProfileMatchQuality {
  needsImprovement,
  good,
  excellent,
}

class ProfileMatchQualityRow extends StatelessWidget {
  const ProfileMatchQualityRow({
    required this.quality,
    this.compact = false,
    super.key,
  });

  final ProfileMatchQuality quality;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final theme = Theme.of(context);

    final data = _getVisualData(locale);

    if (compact) {
      return _QualityBadge(
        label: data.label,
        color: data.color,
      );
    }

    return Row(
      children: [
        Expanded(
          child: Text(
            locale.profileMatchQuality,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        _QualityBadge(label: data.label, color: data.color),
      ],
    );
  }

  _QualityVisualData _getVisualData(S locale) {
    switch (quality) {
      case ProfileMatchQuality.needsImprovement:
        return _QualityVisualData(
          label: locale.needsImprovement,
          color: const Color(0xFFD4A72C),
        );

      case ProfileMatchQuality.good:
        return _QualityVisualData(
          label: locale.good,
          color: const Color(0xFFC88A26),
        );

      case ProfileMatchQuality.excellent:
        return _QualityVisualData(
          label: locale.excellent,
          color: const Color(0xFF4F7A5A),
        );
    }
  }
}

class _QualityBadge extends StatelessWidget {
  const _QualityBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(
          color: color.withValues(alpha: 0.30),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7.r,
            height: 7.r,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 7.w),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _QualityVisualData {
  const _QualityVisualData({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;
}
