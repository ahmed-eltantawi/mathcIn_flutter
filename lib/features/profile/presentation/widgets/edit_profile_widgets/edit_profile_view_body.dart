import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/edit_profile_actions.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/personal_information_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/professional_information_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/professional_links_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/profile_location_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/profile_photo_editor.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditProfileViewBody extends StatefulWidget {
  const EditProfileViewBody({super.key});

  @override
  State<EditProfileViewBody> createState() => _EditProfileViewBodyState();
}

class _EditProfileViewBodyState extends State<EditProfileViewBody> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _dateOfBirthController;
  late final TextEditingController _phoneController;
  late final TextEditingController _jobTitleController;
  late final TextEditingController _githubController;
  late final TextEditingController _linkedinController;

  late final ValueNotifier<String?> _gender;
  late final ValueNotifier<String?> _countryCode;
  late final ValueNotifier<String?> _militaryStatus;
  late final ValueNotifier<String?> _country;
  late final ValueNotifier<String?> _state;
  late final ValueNotifier<String?> _city;

  @override
  void initState() {
    super.initState();

    _fullNameController = TextEditingController();
    _dateOfBirthController = TextEditingController();
    _phoneController = TextEditingController();
    _jobTitleController = TextEditingController();
    _githubController = TextEditingController();
    _linkedinController = TextEditingController();

    _gender = ValueNotifier(null);
    _countryCode = ValueNotifier(null);
    _militaryStatus = ValueNotifier(null);
    _country = ValueNotifier(null);
    _state = ValueNotifier(null);
    _city = ValueNotifier(null);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dateOfBirthController.dispose();
    _phoneController.dispose();
    _jobTitleController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();

    _gender.dispose();
    _countryCode.dispose();
    _militaryStatus.dispose();
    _country.dispose();
    _state.dispose();
    _city.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                locale.editProfile,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),

        SizedBox(height: 24.h),

        const ProfilePhotoEditor(),

        SizedBox(height: 24.h),

        ValueListenableBuilder<String?>(
          valueListenable: _gender,
          builder: (context, gender, child) {
            return ValueListenableBuilder<String?>(
              valueListenable: _countryCode,
              builder: (context, countryCode, child) {
                return PersonalInformationCard(
                  fullNameController: _fullNameController,
                  dateOfBirthController: _dateOfBirthController,
                  phoneController: _phoneController,
                  gender: gender,
                  countryCode: countryCode,

                  // Intentionally empty until a real country-code
                  // source is selected.
                  countryCodes: const {},

                  onGenderChanged: (value) {
                    _gender.value = value;
                  },
                  onCountryCodeChanged: (value) {
                    _countryCode.value = value;
                  },
                );
              },
            );
          },
        ),

        SizedBox(height: 16.h),

        ValueListenableBuilder<String?>(
          valueListenable: _militaryStatus,
          builder: (context, militaryStatus, child) {
            return ProfessionalInformationCard(
              jobTitleController: _jobTitleController,
              militaryStatus: militaryStatus,

              // Exact backend values are not documented yet.
              militaryStatusItems: const {},

              onMilitaryStatusChanged: (value) {
                _militaryStatus.value = value;
              },
            );
          },
        ),

        SizedBox(height: 16.h),

        ValueListenableBuilder<String?>(
          valueListenable: _country,
          builder: (context, country, child) {
            return ValueListenableBuilder<String?>(
              valueListenable: _state,
              builder: (context, state, child) {
                return ValueListenableBuilder<String?>(
                  valueListenable: _city,
                  builder: (context, city, child) {
                    return ProfileLocationCard(
                      country: country,
                      state: state,
                      city: city,

                      // Location source is intentionally not fabricated.
                      countries: const {},
                      states: const {},
                      cities: const {},

                      onCountryChanged: (value) {
                        _country.value = value;
                        _state.value = null;
                        _city.value = null;
                      },
                      onStateChanged: (value) {
                        _state.value = value;
                        _city.value = null;
                      },
                      onCityChanged: (value) {
                        _city.value = value;
                      },
                    );
                  },
                );
              },
            );
          },
        ),

        SizedBox(height: 16.h),

        ProfessionalLinksCard(
          githubController: _githubController,
          linkedinController: _linkedinController,
        ),

        SizedBox(height: 28.h),

        EditProfileActions(
          onSave: () {},
          onCancel: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
