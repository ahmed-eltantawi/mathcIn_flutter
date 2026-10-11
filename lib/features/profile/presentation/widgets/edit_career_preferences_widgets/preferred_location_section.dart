import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/preference_dropdown_field.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/preference_section_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PreferredLocationSection extends StatelessWidget {
  const PreferredLocationSection({
    required this.country,
    required this.state,
    required this.city,
    required this.openToRelocation,
    required this.onCountryPressed,
    required this.onStatePressed,
    required this.onCityPressed,
    required this.onOpenToRelocationChanged,
    super.key,
  });

  final String country;
  final String state;
  final String city;
  final bool openToRelocation;

  final VoidCallback onCountryPressed;
  final VoidCallback onStatePressed;
  final VoidCallback onCityPressed;
  final ValueChanged<bool?> onOpenToRelocationChanged;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return PreferenceSectionCard(
      title: locale.preferredLocation,
      child: Column(
        children: [
          PreferenceDropdownField(
            label: locale.country,
            value: country,
            onPressed: onCountryPressed,
          ),

          SizedBox(height: 16.h),

          // UI-only. Career Preferences API has no preferred_state.
          PreferenceDropdownField(
            label: locale.stateGovernorate,
            value: state,
            onPressed: onStatePressed,
          ),

          SizedBox(height: 16.h),

          PreferenceDropdownField(
            label: locale.city,
            value: city,
            onPressed: onCityPressed,
          ),

          SizedBox(height: 16.h),

          Divider(height: 1, color: colors.outlineVariant),

          SizedBox(height: 12.h),

          InkWell(
            onTap: () => onOpenToRelocationChanged(!openToRelocation),
            borderRadius: BorderRadius.circular(8.r),
            child: Row(
              children: [
                SizedBox(
                  width: 24.r,
                  height: 24.r,
                  child: Checkbox(
                    value: openToRelocation,
                    onChanged: onOpenToRelocationChanged,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    locale.openToOpportunitiesAnywhere,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
