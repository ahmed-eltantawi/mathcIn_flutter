import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EducationProfileItem extends StatelessWidget {
  const EducationProfileItem({
    required this.degree,
    required this.institution,
    this.startDate,
    this.endDate,
    this.grade,
    super.key,
  });

  final String degree;
  final String institution;
  final String? startDate;
  final String? endDate;
  final String? grade;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final date = _formatDate();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          degree,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),

        SizedBox(height: 4.h),

        Text(
          institution,
          style: theme.textTheme.bodyMedium?.copyWith(color: colors.onSurface),
        ),

        if (date.isNotEmpty || _hasGrade) ...[
          SizedBox(height: 6.h),

          Wrap(
            spacing: 8.w,
            runSpacing: 4.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (date.isNotEmpty)
                Text(
                  date,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),

              if (date.isNotEmpty && _hasGrade)
                Text(
                  '•',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),

              if (_hasGrade)
                Text(
                  grade!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  bool get _hasGrade {
    return grade != null && grade!.trim().isNotEmpty;
  }

  String _formatDate() {
    final start = startDate?.trim() ?? '';
    final end = endDate?.trim() ?? '';

    if (start.isEmpty && end.isEmpty) {
      return '';
    }

    if (start.isEmpty) {
      return end;
    }

    if (end.isEmpty) {
      return start;
    }

    return '$start – $end';
  }
}
