import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JobRequirementsCard extends StatelessWidget {
  const JobRequirementsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    const skills = [
      'Flutter',
      'Dart',
      'REST APIs',
      'Git',
      'Testing',
      'CI/CD',
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.jobRequirements,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              '${s.requiredSkills}:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
            SizedBox(height: 6.h),
            Wrap(
              spacing: 7.w,
              runSpacing: 7.h,
              children: skills
                  .map(
                    (skill) =>
                        _RequirementChip(label: skill),
                  )
                  .toList(),
            ),
            SizedBox(height: 16.h),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${s.preferred}: ',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                    ),
                  ),
                  const TextSpan(
                    text: 'Firebase, Clean Architecture',
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${s.experience}: ${s.zeroToTwoYears}',
                  ),
                ),
                Expanded(
                  child: Text(
                    '${s.education}: ${s.csOrRelated}',
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            const Divider(height: 1),
            SizedBox(height: 4.h),
            TextButton.icon(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
              ),
              iconAlignment: IconAlignment.end,
              label: Text(s.viewFullJobDescription),
              icon: const Icon(
                Icons.open_in_new_rounded,
                size: 17,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequirementChip extends StatelessWidget {
  const _RequirementChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 9.w,
        vertical: 5.h,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
