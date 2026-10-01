import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/preference_choice_chip.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/preference_section_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JobTypeSection extends StatelessWidget {
  const JobTypeSection({
    required this.selectedTypes,
    required this.onSelected,
    super.key,
  });

  final Set<String> selectedTypes;
  final void Function(String value, bool isSelected)
  onSelected;

  static const types = [
    'Full-time',
    'Part-time',
    'Internship',
    'Contract',
    'Freelance',
  ];

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final theme = Theme.of(context);

    return PreferenceSectionCard(
      title: locale.jobType,
      trailing: Text(
        locale.multiSelect,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: types.map((type) {
          final selected = selectedTypes.contains(type);

          return PreferenceChoiceChip(
            label: _localized(locale, type),
            isSelected: selected,
            onPressed: () => onSelected(type, !selected),
          );
        }).toList(),
      ),
    );
  }

  String _localized(S locale, String value) {
    return switch (value) {
      'Full-time' => locale.fullTime,
      'Part-time' => locale.partTime,
      'Internship' => locale.internship,
      'Contract' => locale.contract,
      'Freelance' => locale.freelance,
      _ => value,
    };
  }
}
