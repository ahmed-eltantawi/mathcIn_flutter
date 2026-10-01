import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/generated/l10n.dart';

class SkillSuggestions extends StatelessWidget {
  const SkillSuggestions({
    required this.skills,
    required this.onSkillPressed,
    super.key,
  });

  final List<String> skills;
  final ValueChanged<String> onSkillPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final S locale = S.of(context);

    return SizedBox(
      height: 32.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: skills.length + 1,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Center(
              child: Text(
                '${locale.suggestions}:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final skill = skills[index - 1];

          return Center(
            child: ActionChip(
              onPressed: () => onSkillPressed(skill),
              avatar: Icon(
                Icons.add_rounded,
                size: 18.r,
                color: colors.onSurface,
              ),
              label: Text(skill),
              backgroundColor: colors.surface,
              side: BorderSide(color: theme.dividerColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100.r),
              ),
            ),
          );
        },
      ),
    );
  }
}
