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

  final String? selectedLevel;
  final ValueChanged<String> onSelected;

  static const List<String> levels = [
    'student',
    'entry_level',
    'junior',
    'mid_level',
    'senior',
  ];

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return PreferenceSectionCard(
      title: locale.experienceLevel,
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: levels.map((level) {
          return PreferenceChoiceChip(
            label: _localizedLevel(locale, level),
            isSelected: selectedLevel == level,
            onPressed: () => onSelected(level),
          );
        }).toList(),
      ),
    );
  }

  String _localizedLevel(S locale, String value) {
    return switch (value) {
      'student' => locale.student,
      'entry_level' => locale.entryLevel,
      'junior' => locale.junior,
      'mid_level' => locale.midLevel,
      'senior' => locale.senior,
      _ => value,
    };
  }
}
