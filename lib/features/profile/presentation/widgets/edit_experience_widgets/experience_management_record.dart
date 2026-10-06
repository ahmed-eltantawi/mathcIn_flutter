import 'package:MatchIn/features/profile/presentation/widgets/edit_experience_widgets/experience_record_data.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_experience_widgets/experience_skill_chip.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExperienceManagementRecord extends StatelessWidget {
  const ExperienceManagementRecord({
    required this.experience,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final ExperienceRecordData experience;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: double.infinity,
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
                  experience.jobTitle,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          Text(
            experience.companyName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (_hasText(experience.employmentType))
                ExperienceSkillChip(
                  label: experience.employmentType!,
                ),
              if (_hasText(experience.startDate))
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 15.r,
                      color: colors.onSurfaceVariant,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      _dateRange(),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
            ],
          ),
          if (_hasText(experience.location) ||
              _hasText(experience.workMode)) ...[
            SizedBox(height: 10.h),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16.r,
                  color: colors.onSurfaceVariant,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    [
                      if (_hasText(experience.location))
                        experience.location!,
                      if (_hasText(experience.workMode))
                        experience.workMode!,
                    ].join(' • '),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ],
          if (_hasText(experience.description)) ...[
            SizedBox(height: 14.h),
            Text(
              experience.description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
          if (experience.skills.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Divider(color: theme.dividerColor),
            SizedBox(height: 10.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Text(
                    locale.skillsLabel,
                    style: theme.textTheme.labelMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: experience.skills
                        .map(
                          (skill) => ExperienceSkillChip(
                            label: skill,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _dateRange() {
    if (!_hasText(experience.endDate)) {
      return experience.startDate ?? '';
    }

    return '${experience.startDate} – ${experience.endDate}';
  }

  bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
