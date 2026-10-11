import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/preference_choice_chip.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/preference_section_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkModeSection extends StatelessWidget {
  const WorkModeSection({
    required this.selectedMode,
    required this.onSelected,
    super.key,
  });

  final String? selectedMode;
  final ValueChanged<String> onSelected;

  static const List<String> modes = ['remote', 'hybrid', 'on_site'];

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return PreferenceSectionCard(
      title: locale.workMode,
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: modes.map((mode) {
          return PreferenceChoiceChip(
            label: _localized(locale, mode),
            isSelected: selectedMode == mode,
            onPressed: () => onSelected(mode),
          );
        }).toList(),
      ),
    );
  }

  String _localized(S locale, String value) {
    return switch (value) {
      'remote' => locale.remote,
      'hybrid' => locale.hybrid,
      'on_site' => locale.onSite,
      _ => value,
    };
  }
}
