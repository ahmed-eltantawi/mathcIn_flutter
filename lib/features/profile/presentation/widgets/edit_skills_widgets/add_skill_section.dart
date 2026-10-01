import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/skill_search_field.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/skill_suggestions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/generated/l10n.dart';

class AddSkillSection extends StatelessWidget {
  const AddSkillSection({
    required this.suggestions,
    required this.onAddPressed,
    required this.onSuggestionPressed,
    super.key,
  });

  final List<String> suggestions;
  final VoidCallback onAddPressed;
  final ValueChanged<String> onSuggestionPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final S locale = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale.addNewSkill,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),
        SkillSearchField(onAddPressed: onAddPressed),
        SizedBox(height: 16.h),
        SkillSuggestions(
          skills: suggestions,
          onSkillPressed: onSuggestionPressed,
        ),
      ],
    );
  }
}
