import 'package:MatchIn/features/profile/presentation/widgets/edit_education_widgets/education_record_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EducationManagementRecord extends StatelessWidget {
  const EducationManagementRecord({
    required this.education,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final EducationRecordData education;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  education.degree,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: Icon(Icons.edit_outlined, color: colors.primary),
              ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline, color: colors.error),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(education.institution, style: theme.textTheme.titleMedium),
          if (education.startDate != null) ...[
            SizedBox(height: 16.h),
            Divider(color: theme.dividerColor),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 17.r,
                  color: colors.onSurfaceVariant,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    education.endDate == null
                        ? education.startDate!
                        : '${education.startDate} – ${education.endDate}',
                  ),
                ),
                if (education.grade != null &&
                    education.grade!.trim().isNotEmpty)
                  Text(
                    education.grade!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
