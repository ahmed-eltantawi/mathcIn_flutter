import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/preference_choice_chip.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/preference_section_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JobTypeSection extends StatelessWidget {
  const JobTypeSection({
    required this.selectedType,
    required this.onSelected,
    super.key,
  });

  final String? selectedType;
  final ValueChanged<String> onSelected;

  static const List<String> types = [
    'full_time',
    'part_time',
    'internship',
    'contract',
    'freelance',
  ];

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return PreferenceSectionCard(
      title: locale.jobType,
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: types.map((type) {
          return PreferenceChoiceChip(
            label: _localized(locale, type),
            isSelected: selectedType == type,
            onPressed: () => onSelected(type),
          );
        }).toList(),
      ),
    );
  }

  String _localized(S locale, String value) {
    return switch (value) {
      'full_time' => locale.fullTime,
      'part_time' => locale.partTime,
      'internship' => locale.internship,
      'contract' => locale.contract,
      'freelance' => locale.freelance,
      _ => value,
    };
  }
}
