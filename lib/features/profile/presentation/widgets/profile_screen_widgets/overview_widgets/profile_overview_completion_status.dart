import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileOverviewCompletionStatus extends StatelessWidget {
  const ProfileOverviewCompletionStatus({
    required this.missingFields,
    super.key,
  });

  final List<String> missingFields;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final locale = S.of(context);
    final isComplete = missingFields.isEmpty;
    final statusColor = isComplete ? colors.primary : colors.error;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.06),
        border: Border.all(color: statusColor, width: 1.2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isComplete ? Icons.check_circle_outline : Icons.error_outline,
                size: 19.r,
                color: statusColor,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  locale.careerProfile,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                isComplete ? locale.excellent : locale.almostComplete,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (!isComplete) ...[
            SizedBox(height: 8.h),
            Text(
              '${locale.needsImprovement}: ${missingFields.join(' • ')}',
              style: theme.textTheme.bodySmall?.copyWith(color: colors.error),
            ),
          ],
        ],
      ),
    );
  }
}
