import 'package:MatchIn/features/profile/presentation/widgets/edit_experience_widgets/experience_dropdown_field.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_experience_widgets/experience_form_actions.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_experience_widgets/experience_form_field.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExperienceForm extends StatefulWidget {
  const ExperienceForm({super.key});

  @override
  State<ExperienceForm> createState() => _ExperienceFormState();
}

class _ExperienceFormState extends State<ExperienceForm> {
  late final TextEditingController _jobTitleController;
  late final TextEditingController _companyController;
  late final TextEditingController _locationController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _relatedSkillsController;

  late final ValueNotifier<String?> _employmentType;
  late final ValueNotifier<String?> _workMode;
  late final ValueNotifier<bool> _isCurrent;

  @override
  void initState() {
    super.initState();

    _jobTitleController = TextEditingController();
    _companyController = TextEditingController();
    _locationController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    _descriptionController = TextEditingController();
    _relatedSkillsController = TextEditingController();

    _employmentType = ValueNotifier(null);
    _workMode = ValueNotifier(null);
    _isCurrent = ValueNotifier(false);
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    _relatedSkillsController.dispose();

    _employmentType.dispose();
    _workMode.dispose();
    _isCurrent.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final theme = Theme.of(context);

    final employmentTypes = <String, String>{
      'full_time': locale.fullTime,
      'part_time': locale.partTime,
      'contract': locale.contract,
      'internship': locale.internship,
      'freelance': locale.freelance,
    };

    final workModes = <String, String>{
      'remote': locale.remote,
      'hybrid': locale.hybrid,
      'on_site': locale.onSite,
    };

    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale.addNewExperience,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 18.h),
          Divider(color: theme.dividerColor),
          SizedBox(height: 18.h),
          ExperienceFormField(
            label: locale.jobTitle,
            controller: _jobTitleController,
            hintText: locale.jobTitleHint,
          ),
          SizedBox(height: 18.h),
          ExperienceFormField(
            label: locale.company,
            controller: _companyController,
            hintText: locale.companyHint,
          ),
          SizedBox(height: 18.h),
          ValueListenableBuilder<String?>(
            valueListenable: _employmentType,
            builder: (context, value, child) {
              return ValueListenableBuilder<String?>(
                valueListenable: _workMode,
                builder: (context, workMode, child) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ExperienceDropdownField(
                          label: locale.employmentType,
                          value: value,
                          items: employmentTypes,
                          onChanged: (newValue) {
                            _employmentType.value = newValue;
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ExperienceDropdownField(
                          label: locale.workMode,
                          value: workMode,
                          items: workModes,
                          onChanged: (newValue) {
                            _workMode.value = newValue;
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          SizedBox(height: 18.h),
          ExperienceFormField(
            label: locale.location,
            controller: _locationController,
            hintText: locale.locationHint,
          ),
          SizedBox(height: 18.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ExperienceFormField(
                  label: locale.startDate,
                  controller: _startDateController,
                  readOnly: true,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ExperienceFormField(
                  label: locale.endDate,
                  controller: _endDateController,
                  readOnly: true,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ValueListenableBuilder<bool>(
            valueListenable: _isCurrent,
            builder: (context, isCurrent, child) {
              return CheckboxListTile(
                value: isCurrent,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(locale.currentlyWorkHere),
                onChanged: (value) {
                  _isCurrent.value = value ?? false;

                  if (_isCurrent.value) {
                    _endDateController.clear();
                  }
                },
              );
            },
          ),
          SizedBox(height: 8.h),
          ExperienceFormField(
            label: locale.responsibilitiesDescription,
            controller: _descriptionController,
            hintText: locale.responsibilitiesHint,
            maxLines: 5,
          ),
          SizedBox(height: 18.h),

          // No Add button inside this field by design.
          ExperienceFormField(
            label: locale.relatedSkills,
            controller: _relatedSkillsController,
            hintText: locale.relatedSkillsHint,
          ),

          SizedBox(height: 24.h),
          Divider(color: theme.dividerColor),
          SizedBox(height: 16.h),
          ExperienceFormActions(onCancel: () {}, onSave: () {}),
        ],
      ),
    );
  }
}
