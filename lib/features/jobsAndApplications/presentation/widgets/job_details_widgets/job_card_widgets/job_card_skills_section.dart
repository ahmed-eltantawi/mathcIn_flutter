import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JobCardSkillsSection extends StatelessWidget {
  const JobCardSkillsSection({
    super.key,
    required this.skills,
  });

  final List<String> skills;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: skills
          .map(
            (skill) => Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 1.h,
              ),
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: context.theme.dividerColor,
                ),
              ),
              child: Text(
                skill,
                style: context.textTheme.labelMedium,
              ),
            ),
          )
          .toList(),
    );
  }
}
