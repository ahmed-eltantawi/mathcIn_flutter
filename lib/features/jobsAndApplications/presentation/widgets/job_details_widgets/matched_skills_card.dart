import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MatchedSkillsCard extends StatelessWidget {
  const MatchedSkillsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.forestGreen,
                ),
                SizedBox(width: 7.w),
                Expanded(
                  child: Text(
                    s.whatYouAlreadyMatch,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                _SourceChip(label: s.fromYourCv),
              ],
            ),
            SizedBox(height: 8.h),
            _MatchedSkill(
              title: 'Flutter',
              subtitle: s.foundInCvAndProjects,
            ),
            _MatchedSkill(
              title: 'REST APIs',
              subtitle: s.usedInTwoProjects,
            ),
            _MatchedSkill(
              title: 'Git & GitHub',
              subtitle: s.foundInYourSkills,
            ),
            _MatchedSkill(
              title: 'State Management',
              subtitle: s.experienceWithBloc,
              showDivider: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchedSkill extends StatelessWidget {
  const _MatchedSkill({
    required this.title,
    required this.subtitle,
    this.showDivider = true,
  });

  final String title;
  final String subtitle;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_rounded,
                color: AppColors.forestGreen,
                size: 19,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(
                            color: theme
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: 28.w,
            ),
            child: const Divider(height: 1),
          ),
      ],
    );
  }
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
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
