import 'package:MatchIn/features/profile/presentation/widgets/edit_experience_widgets/experience_form_actions.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_experience_widgets/experience_form_field.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExperienceForm extends StatefulWidget {
  const ExperienceForm({super.key});

  @override
  State<ExperienceForm> createState() =>
      _ExperienceFormState();
}

class _ExperienceFormState extends State<ExperienceForm> {
  late final TextEditingController _jobTitleController;
  late final TextEditingController _companyController;
  late final TextEditingController
  _employmentTypeController;
  late final TextEditingController _locationController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _skillsController;

  final ValueNotifier<bool> _isCurrent = ValueNotifier(
    false,
  );

  @override
  void initState() {
    super.initState();
    _jobTitleController = TextEditingController();
    _companyController = TextEditingController();
    _employmentTypeController = TextEditingController();
    _locationController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    _descriptionController = TextEditingController();
    _skillsController = TextEditingController();
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _companyController.dispose();
    _employmentTypeController.dispose();
    _locationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    _skillsController.dispose();
    _isCurrent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16.r),
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
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 20.h),

          ExperienceFormField(
            label: locale.jobTitle,
            hintText: locale.jobTitleHint,
            controller: _jobTitleController,
          ),

          SizedBox(height: 16.h),

          ExperienceFormField(
            label: locale.company,
            hintText: locale.companyHint,
            controller: _companyController,
          ),

          SizedBox(height: 16.h),

          ExperienceFormField(
            label: locale.employmentType,
            controller: _employmentTypeController,
          ),

          SizedBox(height: 16.h),

          ExperienceFormField(
            label: locale.location,
            hintText: locale.locationHint,
            controller: _locationController,
          ),

          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: ExperienceFormField(
                  label: locale.startDate,
                  controller: _startDateController,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ExperienceFormField(
                  label: locale.endDate,
                  controller: _endDateController,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          ValueListenableBuilder<bool>(
            valueListenable: _isCurrent,
            builder: (context, value, child) {
              return CheckboxListTile(
                value: value,
                contentPadding: EdgeInsets.zero,
                controlAffinity:
                    ListTileControlAffinity.leading,
                title: Text(locale.currentlyWorkHere),
                onChanged: (newValue) {
                  _isCurrent.value = newValue ?? false;
                },
              );
            },
          ),

          SizedBox(height: 12.h),

          ExperienceFormField(
            label: locale.responsibilitiesDescription,
            hintText: locale.responsibilitiesHint,
            controller: _descriptionController,
            maxLines: 5,
          ),

          SizedBox(height: 16.h),

          ExperienceFormField(
            label: locale.relatedSkills,
            hintText: locale.relatedSkillsHint,
            controller: _skillsController,
          ),

          SizedBox(height: 24.h),

          ExperienceFormActions(
            onCancel: () {},
            onSave: () {},
          ),
        ],
      ),
    );
  }
}
