import 'package:MatchIn/features/profile/presentation/widgets/edit_education_widgets/education_form_actions.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_education_widgets/education_form_field.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EducationForm extends StatefulWidget {
  const EducationForm({super.key});

  @override
  State<EducationForm> createState() => _EducationFormState();
}

class _EducationFormState extends State<EducationForm> {
  late final TextEditingController _degreeController;
  late final TextEditingController _fieldController;
  late final TextEditingController _institutionController;
  late final TextEditingController _startController;
  late final TextEditingController _endController;
  late final TextEditingController _gradeController;

  late final ValueNotifier<bool> _isCurrent;

  @override
  void initState() {
    super.initState();

    _degreeController = TextEditingController();
    _fieldController = TextEditingController();
    _institutionController = TextEditingController();
    _startController = TextEditingController();
    _endController = TextEditingController();
    _gradeController = TextEditingController();

    _isCurrent = ValueNotifier(false);
  }

  @override
  void dispose() {
    _degreeController.dispose();
    _fieldController.dispose();
    _institutionController.dispose();
    _startController.dispose();
    _endController.dispose();
    _gradeController.dispose();
    _isCurrent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final theme = Theme.of(context);

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
            locale.addNewEducation,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),
          Divider(color: theme.dividerColor),
          SizedBox(height: 16.h),
          EducationFormField(
            label: locale.degree,
            controller: _degreeController,
            hintText: locale.degreeHint,
          ),
          SizedBox(height: 18.h),
          EducationFormField(
            label: locale.fieldOfStudy,
            controller: _fieldController,
            hintText: locale.fieldOfStudyHint,
          ),
          SizedBox(height: 18.h),
          EducationFormField(
            label: locale.schoolUniversity,
            controller: _institutionController,
            hintText: locale.institutionHint,
          ),
          SizedBox(height: 18.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: EducationFormField(
                  label: locale.startYear,
                  controller: _startController,
                  hintText: locale.select,
                  readOnly: true,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: EducationFormField(
                  label: locale.endYearExpected,
                  controller: _endController,
                  hintText: locale.select,
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
                title: Text(locale.currentlyStudyingHere),
                onChanged: (value) {
                  _isCurrent.value = value ?? false;

                  if (_isCurrent.value) {
                    _endController.clear();
                  }
                },
              );
            },
          ),
          SizedBox(height: 8.h),
          EducationFormField(
            label: locale.gpaOptional,
            controller: _gradeController,
            hintText: locale.gpaHint,
          ),
          SizedBox(height: 24.h),
          Divider(color: theme.dividerColor),
          SizedBox(height: 16.h),
          EducationFormActions(onCancel: () {}, onSave: () {}),
        ],
      ),
    );
  }
}
