import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/edit_profile_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/edit_profile_dropdown.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileLocationCard extends StatelessWidget {
  const ProfileLocationCard({
    required this.country,
    required this.state,
    required this.city,
    required this.countries,
    required this.states,
    required this.cities,
    required this.onCountryChanged,
    required this.onStateChanged,
    required this.onCityChanged,
    super.key,
  });

  final String? country;
  final String? state;
  final String? city;

  final Map<String, String> countries;
  final Map<String, String> states;
  final Map<String, String> cities;

  final ValueChanged<String?> onCountryChanged;
  final ValueChanged<String?> onStateChanged;
  final ValueChanged<String?> onCityChanged;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return EditProfileCard(
      title: locale.location,
      child: Column(
        children: [
          EditProfileDropdown(
            label: locale.country,
            value: country,
            items: countries,
            onChanged: onCountryChanged,
          ),
          SizedBox(height: 16.h),
          EditProfileDropdown(
            label: locale.stateGovernorate,
            value: state,
            items: states,
            onChanged: onStateChanged,
          ),
          SizedBox(height: 16.h),
          EditProfileDropdown(
            label: locale.city,
            value: city,
            items: cities,
            onChanged: onCityChanged,
          ),
        ],
      ),
    );
  }
}
