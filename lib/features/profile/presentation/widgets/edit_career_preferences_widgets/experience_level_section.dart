import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/preference_choice_chip.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/preference_section_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExperienceLevelSection extends StatelessWidget {
  const ExperienceLevelSection({
    required this.selectedLevel,
    required this.onSelected,
    super.key,
  });

  final String selectedLevel;
  final ValueChanged<String> onSelected;

  static const levels = [
    'Student',
    'Entry Level',
    'Junior',
    'Mid-Level',
    'Senior',
  ];

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return PreferenceSectionCard(
      title: locale.experienceLevel,
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: levels
            .map(
              (level) => PreferenceChoiceChip(
                label: _localizedLevel(locale, level),
                isSelected: level == selectedLevel,
                onPressed: () => onSelected(level),
              ),
            )
            .toList(),
      ),
    );
  }

  String _localizedLevel(S locale, String value) {
    return switch (value) {
      'Student' => locale.student,
      'Entry Level' => locale.entryLevel,
      'Junior' => locale.junior,
      'Mid-Level' => locale.midLevel,
      'Senior' => locale.senior,
      _ => value,
    };
  }
}
