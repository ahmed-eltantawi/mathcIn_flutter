import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/experience_widgets/experience_profile_item_data.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/experience_widgets/experience_technology_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExperienceProfileItem extends StatelessWidget {
  const ExperienceProfileItem({
    required this.experience,
    super.key,
  });

  final ExperienceProfileItemData experience;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final location = _formatLocation();
    final date = _formatDate();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                experience.jobTitle,
                style: theme.textTheme.titleMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
              ),
            ),

            if (date.isNotEmpty) ...[
              SizedBox(width: 8.w),
              Text(
                date,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),

        SizedBox(height: 3.h),

        Text(
          experience.companyName,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurface,
          ),
        ),

        if (_hasMetaData) ...[
          SizedBox(height: 8.h),

          Wrap(
            spacing: 8.w,
            runSpacing: 5.h,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (_hasEmploymentType)
                Text(
                  experience.employmentType!,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),

              if (location.isNotEmpty)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 15.r,
                      color: colors.onSurfaceVariant,
                    ),
                    SizedBox(width: 3.w),
                    Text(
                      location,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
            ],
          ),
        ],

        if (_hasDescription) ...[
          SizedBox(height: 10.h),

          Text(
            experience.description!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],

        if (experience.technologies.isNotEmpty) ...[
          SizedBox(height: 12.h),

          Wrap(
            spacing: 7.w,
            runSpacing: 7.h,
            children: experience.technologies
                .map(
                  (technology) => ExperienceTechnologyChip(
                    label: technology,
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }

  bool get _hasEmploymentType {
    return experience.employmentType != null &&
        experience.employmentType!.trim().isNotEmpty;
  }

  bool get _hasDescription {
    return experience.description != null &&
        experience.description!.trim().isNotEmpty;
  }

  bool get _hasMetaData {
    return _hasEmploymentType ||
        _formatLocation().isNotEmpty;
  }

  String _formatLocation() {
    return [experience.city, experience.country]
        .where(
          (value) =>
              value != null && value.trim().isNotEmpty,
        )
        .join(', ');
  }

  String _formatDate() {
    final start = experience.startDate?.trim() ?? '';

    if (experience.isCurrent) {
      return start.isEmpty ? 'Present' : '$start – Present';
    }

    final end = experience.endDate?.trim() ?? '';

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
