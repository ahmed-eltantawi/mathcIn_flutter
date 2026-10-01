import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/preference_choice_chip.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/preference_section_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkModeSection extends StatelessWidget {
  const WorkModeSection({
    required this.selectedModes,
    required this.onSelected,
    super.key,
  });

  final Set<String> selectedModes;
  final void Function(String value, bool isSelected)
  onSelected;

  static const modes = ['Remote', 'Hybrid', 'On-site'];

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final theme = Theme.of(context);

    return PreferenceSectionCard(
      title: locale.workMode,
      trailing: Text(
        locale.flexible,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: modes.map((mode) {
          final selected = selectedModes.contains(mode);

          return PreferenceChoiceChip(
            label: _localized(locale, mode),
            isSelected: selected,
            onPressed: () => onSelected(mode, !selected),
          );
        }).toList(),
      ),
    );
  }

  String _localized(S locale, String value) {
    return switch (value) {
      'Remote' => locale.remote,
      'Hybrid' => locale.hybrid,
      'On-site' => locale.onSite,
      _ => value,
    };
  }
}
