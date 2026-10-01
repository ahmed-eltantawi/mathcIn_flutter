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
    required this.openToAnywhere,
    required this.onCountryPressed,
    required this.onStatePressed,
    required this.onCityPressed,
    required this.onOpenToAnywhereChanged,
    super.key,
  });

  final String country;
  final String state;
  final String city;
  final bool openToAnywhere;

  final VoidCallback onCountryPressed;
  final VoidCallback onStatePressed;
  final VoidCallback onCityPressed;
  final ValueChanged<bool?> onOpenToAnywhereChanged;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

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
            onTap: () =>
                onOpenToAnywhereChanged(!openToAnywhere),
            borderRadius: BorderRadius.circular(8.r),
            child: Row(
              children: [
                SizedBox(
                  width: 24.r,
                  height: 24.r,
                  child: Checkbox(
                    value: openToAnywhere,
                    onChanged: onOpenToAnywhereChanged,
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
