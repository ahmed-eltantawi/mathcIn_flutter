import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/edit_profile_actions.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/edit_profile_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/edit_profile_field.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditProfileViewBody extends StatefulWidget {
  const EditProfileViewBody({super.key});

  @override
  State<EditProfileViewBody> createState() =>
      _EditProfileViewBodyState();
}

class _EditProfileViewBodyState
    extends State<EditProfileViewBody> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _dateOfBirthController;
  late final TextEditingController _phoneController;
  late final TextEditingController _jobTitleController;
  late final TextEditingController
  _militaryStatusController;
  late final TextEditingController _countryController;
  late final TextEditingController _stateController;
  late final TextEditingController _cityController;
  late final TextEditingController _githubController;
  late final TextEditingController _linkedinController;

  @override
  void initState() {
    super.initState();

    _fullNameController = TextEditingController();
    _dateOfBirthController = TextEditingController();
    _phoneController = TextEditingController();
    _jobTitleController = TextEditingController();
    _militaryStatusController = TextEditingController();
    _countryController = TextEditingController();
    _stateController = TextEditingController();
    _cityController = TextEditingController();
    _githubController = TextEditingController();
    _linkedinController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dateOfBirthController.dispose();
    _phoneController.dispose();
    _jobTitleController.dispose();
    _militaryStatusController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _githubController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        SizedBox(height: 8.h),
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
            ),
            SizedBox(width: 8.w),
            Text(
              locale.editProfile,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        SizedBox(height: 24.h),

        EditProfileCard(
          title: locale.personalInformation,
          child: Column(
            children: [
              EditProfileField(
                label: locale.fullName,
                controller: _fullNameController,
              ),
              SizedBox(height: 16.h),
              EditProfileField(
                label: locale.dateOfBirth,
                controller: _dateOfBirthController,
                readOnly: true,
              ),
              SizedBox(height: 16.h),
              EditProfileField(
                label: locale.phoneNumber,
                controller: _phoneController,
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        EditProfileCard(
          title: locale.professionalInformation,
          child: Column(
            children: [
              EditProfileField(
                label: locale.jobTitle,
                controller: _jobTitleController,
              ),
              SizedBox(height: 16.h),
              EditProfileField(
                label: locale.militaryStatus,
                controller: _militaryStatusController,
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        EditProfileCard(
          title: locale.location,
          child: Column(
            children: [
              EditProfileField(
                label: locale.country,
                controller: _countryController,
              ),
              SizedBox(height: 16.h),
              EditProfileField(
                label: locale.stateGovernorate,
                controller: _stateController,
              ),
              SizedBox(height: 16.h),
              EditProfileField(
                label: locale.city,
                controller: _cityController,
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        EditProfileCard(
          title: locale.professionalLinks,
          child: Column(
            children: [
              EditProfileField(
                label: locale.github,
                controller: _githubController,
              ),
              SizedBox(height: 16.h),
              EditProfileField(
                label: locale.linkedin,
                controller: _linkedinController,
              ),
            ],
          ),
        ),

        SizedBox(height: 24.h),

        EditProfileActions(
          onSave: () {},
          onCancel: () => Navigator.of(context).pop(),
        ),

        SizedBox(height: 24.h),
      ],
    );
  }
}
