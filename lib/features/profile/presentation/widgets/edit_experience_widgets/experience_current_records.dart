import 'package:MatchIn/features/profile/presentation/widgets/edit_experience_widgets/experience_management_record.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_experience_widgets/experience_record_data.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExperienceCurrentRecords extends StatelessWidget {
  const ExperienceCurrentRecords({
    required this.experiences,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final List<ExperienceRecordData> experiences;
  final ValueChanged<ExperienceRecordData> onEdit;
  final ValueChanged<ExperienceRecordData> onDelete;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${locale.currentRecords} (${experiences.length})',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              locale.sortedByRecent,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
        if (experiences.isNotEmpty) ...[
          SizedBox(height: 14.h),
          for (
            int index = 0;
            index < experiences.length;
            index++
          ) ...[
            ExperienceManagementRecord(
              experience: experiences[index],
              onEdit: () => onEdit(experiences[index]),
              onDelete: () => onDelete(experiences[index]),
            ),
            if (index != experiences.length - 1)
              SizedBox(height: 12.h),
          ],
        ],
      ],
    );
  }
}
