import 'package:MatchIn/features/profile/presentation/widgets/edit_education_widgets/education_form_actions.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_education_widgets/education_form_field.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EducationForm extends StatefulWidget {
  const EducationForm({super.key});

  @override
  State<EducationForm> createState() =>
      _EducationFormState();
}

class _EducationFormState extends State<EducationForm> {
  late final TextEditingController _degreeController;
  late final TextEditingController _fieldController;
  late final TextEditingController _institutionController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;
  late final TextEditingController _gradeController;

  final ValueNotifier<bool> _isCurrent = ValueNotifier(
    false,
  );

  @override
  void initState() {
    super.initState();
    _degreeController = TextEditingController();
    _fieldController = TextEditingController();
    _institutionController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    _gradeController = TextEditingController();
  }

  @override
  void dispose() {
    _degreeController.dispose();
    _fieldController.dispose();
    _institutionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _gradeController.dispose();
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
            locale.addNewEducation,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 20.h),

          EducationFormField(
            label: locale.degree,
            hintText: locale.degreeHint,
            controller: _degreeController,
          ),
          SizedBox(height: 16.h),

          EducationFormField(
            label: locale.fieldOfStudy,
            hintText: locale.fieldOfStudyHint,
            controller: _fieldController,
          ),
          SizedBox(height: 16.h),

          EducationFormField(
            label: locale.schoolUniversity,
            hintText: locale.institutionHint,
            controller: _institutionController,
          ),
          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: EducationFormField(
                  label: locale.startYear,
                  controller: _startDateController,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: EducationFormField(
                  label: locale.endYearExpected,
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
                title: Text(locale.currentlyStudyingHere),
                onChanged: (newValue) {
                  _isCurrent.value = newValue ?? false;
                },
              );
            },
          ),

          SizedBox(height: 12.h),

          EducationFormField(
            label: locale.gpaOptional,
            hintText: locale.gpaHint,
            controller: _gradeController,
          ),

          SizedBox(height: 24.h),

          EducationFormActions(
            onCancel: () {},
            onSave: () {},
          ),
        ],
      ),
    );
  }
}
