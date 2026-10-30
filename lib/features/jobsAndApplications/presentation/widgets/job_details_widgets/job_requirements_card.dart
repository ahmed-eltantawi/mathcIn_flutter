import 'package:MatchIn/generated/l10n.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JobRequirementsCard extends StatelessWidget {
  const JobRequirementsCard({super.key, required this.job});

  final JobEntity job;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    final requiredSkills =
        job.requiredSkills?.map((skill) => skill.name).toList() ?? job.skills;
    final preferredSkills =
        job.preferredSkills?.map((skill) => skill.name).toList() ??
        const <String>[];
    final description = job.description?.trim();

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
            if (requiredSkills.isNotEmpty)
              Text(
                '${s.requiredSkills}:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            if (requiredSkills.isNotEmpty) SizedBox(height: 6.h),
            if (requiredSkills.isNotEmpty)
              Wrap(
                spacing: 7.w,
                runSpacing: 7.h,
                children: requiredSkills
                    .map((skill) => _RequirementChip(label: skill))
                    .toList(),
              ),
            if (preferredSkills.isNotEmpty) SizedBox(height: 16.h),
            if (preferredSkills.isNotEmpty)
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${s.preferred}: ',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                    TextSpan(text: preferredSkills.join(', ')),
                  ],
                ),
              ),
            if (requiredSkills.isEmpty && preferredSkills.isEmpty)
              Text(s.noJobRequirementsListed),
            if (description != null && description.isNotEmpty) ...[
              SizedBox(height: 12.h),
              const Divider(height: 1),
              SizedBox(height: 4.h),
              TextButton.icon(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    title: Text(job.title),
                    content: SingleChildScrollView(child: Text(description)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        child: Text(s.cancel),
                      ),
                    ],
                  ),
                ),
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                iconAlignment: IconAlignment.end,
                label: Text(s.viewFullJobDescription),
                icon: const Icon(Icons.open_in_new_rounded, size: 17),
              ),
            ],
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
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
