import 'package:MatchIn/features/profile/domain/entities/add_education_params.dart';
import 'package:MatchIn/features/profile/domain/entities/education_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_education_params.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/profile_form_validator.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_education_widgets/education_form_actions.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_education_widgets/education_form_field.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EducationForm extends StatefulWidget {
  const EducationForm({
    super.key,
    this.initialEducation,
    this.isSaving = false,
    required this.onAdd,
    required this.onUpdate,
    required this.onCancel,
  });

  /// Null means Add mode; non-null switches the same form to Edit mode.
  final EducationEntity? initialEducation;
  final bool isSaving;
  final ValueChanged<AddEducationParams> onAdd;
  final ValueChanged<UpdateEducationParams> onUpdate;
  final VoidCallback onCancel;

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
  late final ValueNotifier<DateTime?> _startDate;
  late final ValueNotifier<DateTime?> _endDate;

  bool get _isEditing => widget.initialEducation != null;

  @override
  void initState() {
    super.initState();

    final initial = widget.initialEducation;

    _degreeController = TextEditingController(text: initial?.degree ?? '');
    _fieldController = TextEditingController(text: initial?.fieldOfStudy ?? '');
    _institutionController = TextEditingController(
      text: initial?.institution ?? '',
    );
    _startController = TextEditingController(text: initial?.startDate ?? '');
    _endController = TextEditingController(text: initial?.endDate ?? '');
    _gradeController = TextEditingController(text: initial?.grade ?? '');

    _isCurrent = ValueNotifier<bool>(initial?.isCurrent ?? false);
    _startDate = ValueNotifier<DateTime?>(
      ProfileFormValidator.parseDate(initial?.startDate),
    );
    _endDate = ValueNotifier<DateTime?>(
      ProfileFormValidator.parseDate(initial?.endDate),
    );
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
    _startDate.dispose();
    _endDate.dispose();
    super.dispose();
  }

  Future<void> _pickDate({
    required ValueNotifier<DateTime?> notifier,
    required TextEditingController controller,
  }) async {
    if (widget.isSaving) return;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: notifier.value ?? now,
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year + 10, 12, 31),
    );
    if (picked == null) return;
    notifier.value = DateTime(picked.year, picked.month, picked.day);
    controller.text = ProfileFormValidator.formatDate(notifier.value!);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  static String? _normalizedOrNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  void _handleSave() {
    if (widget.isSaving) return;
    final locale = S.of(context);

    final institution = _institutionController.text.trim();
    if (institution.isEmpty) {
      _showMessage(locale.required);
      return;
    }

    final isCurrent = _isCurrent.value;
    final start = _startDate.value;
    final end = isCurrent ? null : _endDate.value;

    final rangeError = ProfileFormValidator.validateDateRange(
      start: start,
      end: end,
      invalidMessage: locale.invalidDateRange,
    );
    if (rangeError != null) {
      _showMessage(rangeError);
      return;
    }

    final startText = start == null
        ? null
        : ProfileFormValidator.formatDate(start);
    final endText = end == null ? null : ProfileFormValidator.formatDate(end);

    final baseline = widget.initialEducation;
    if (baseline == null) {
      widget.onAdd(
        AddEducationParams(
          institution: institution,
          degree: _normalizedOrNull(_degreeController.text),
          fieldOfStudy: _normalizedOrNull(_fieldController.text),
          grade: _normalizedOrNull(_gradeController.text),
          isCurrent: isCurrent,
          startDate: startText,
          endDate: endText,
        ),
      );
      return;
    }

    var params = UpdateEducationParams(educationId: baseline.id);

    if (institution != baseline.institution) {
      params = params.copyWith(
        educationId: baseline.id,
        institution: institution,
      );
    }

    final degree = _normalizedOrNull(_degreeController.text);
    if (degree != _normalizedOrNull(baseline.degree)) {
      params = params.copyWith(educationId: baseline.id, degree: degree);
    }

    final fieldOfStudy = _normalizedOrNull(_fieldController.text);
    if (fieldOfStudy != baseline.fieldOfStudy) {
      params = params.copyWith(
        educationId: baseline.id,
        fieldOfStudy: fieldOfStudy,
      );
    }

    final grade = _normalizedOrNull(_gradeController.text);
    if (grade != baseline.grade) {
      params = params.copyWith(educationId: baseline.id, grade: grade);
    }

    if (isCurrent != baseline.isCurrent) {
      params = params.copyWith(
        educationId: baseline.id,
        isCurrent: isCurrent,
        // is_current=true requires end_date to be absent/null:
        // explicitly clear a previously stored end date.
        endDate: isCurrent ? null : endText,
      );
    } else {
      if (startText != baseline.startDate) {
        params = params.copyWith(
          educationId: baseline.id,
          startDate: startText,
        );
      }
      if (!isCurrent && endText != baseline.endDate) {
        params = params.copyWith(educationId: baseline.id, endDate: endText);
      }
    }

    if (!params.hasChanges) {
      widget.onCancel();
      return;
    }

    widget.onUpdate(params);
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
            _isEditing ? locale.editEducation : locale.addNewEducation,
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
            // Bottom-aligned so both date inputs sit at the same
            // vertical position even when the labels wrap to a
            // different number of lines.
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: EducationFormField(
                  label: locale.startYear,
                  controller: _startController,
                  hintText: locale.select,
                  readOnly: true,
                  onTap: () => _pickDate(
                    notifier: _startDate,
                    controller: _startController,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _isCurrent,
                  builder: (context, isCurrent, child) {
                    return Opacity(
                      opacity: isCurrent ? 0.5 : 1.0,
                      child: EducationFormField(
                        label: locale.endYearExpected,
                        controller: _endController,
                        hintText: locale.select,
                        readOnly: true,
                        onTap: isCurrent
                            ? null
                            : () => _pickDate(
                                notifier: _endDate,
                                controller: _endController,
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ValueListenableBuilder<bool>(
            valueListenable: _isCurrent,
            builder: (context, isCurrent, child) {
              return Material(
                type: MaterialType.transparency,
                child: CheckboxListTile(
                  value: isCurrent,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(locale.currentlyStudyingHere),
                  onChanged: widget.isSaving
                      ? null
                      : (value) {
                          _isCurrent.value = value ?? false;

                          if (_isCurrent.value) {
                            _endDate.value = null;
                            _endController.clear();
                          }
                        },
                ),
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
          EducationFormActions(
            isSaving: widget.isSaving,
            onCancel: widget.onCancel,
            onSave: _handleSave,
          ),
        ],
      ),
    );
  }
}
