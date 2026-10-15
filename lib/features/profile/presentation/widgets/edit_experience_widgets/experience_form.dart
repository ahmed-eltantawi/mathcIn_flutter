import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/profile/data/data_sources/location/location_catalog.dart';
import 'package:MatchIn/features/profile/domain/entities/add_experience_params.dart';
import 'package:MatchIn/features/profile/domain/entities/experience_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_experience_params.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/profile_form_validator.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_experience_widgets/experience_technologies_parser.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_experience_widgets/experience_dropdown_field.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_experience_widgets/experience_form_actions.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_experience_widgets/experience_form_field.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExperienceForm extends StatefulWidget {
  const ExperienceForm({
    super.key,
    this.initialExperience,
    this.isSaving = false,
    required this.onAdd,
    required this.onUpdate,
    required this.onCancel,
  });

  /// Null means Add mode; non-null switches the same form to Edit mode.
  final ExperienceEntity? initialExperience;
  final bool isSaving;
  final ValueChanged<AddExperienceParams> onAdd;
  final ValueChanged<UpdateExperienceParams> onUpdate;
  final VoidCallback onCancel;

  @override
  State<ExperienceForm> createState() => _ExperienceFormState();
}

class _ExperienceFormState extends State<ExperienceForm> {
  late final TextEditingController _jobTitleController;
  late final TextEditingController _companyController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _relatedSkillsController;

  late final ValueNotifier<String?> _employmentType;
  late final ValueNotifier<DateTime?> _startDate;
  late final ValueNotifier<DateTime?> _endDate;
  late final ValueNotifier<bool> _isCurrent;

  late final ValueNotifier<String?> _country;
  late final ValueNotifier<String?> _state;
  late final ValueNotifier<String?> _city;

  late final ValueNotifier<Map<String, String>> _stateOptions;
  late final ValueNotifier<Map<String, String>> _cityOptions;

  int _statesRequest = 0;
  int _citiesRequest = 0;

  LocationCatalog get _locationCatalog => getIt<LocationCatalog>();

  bool get _isEditing => widget.initialExperience != null;

  @override
  void initState() {
    super.initState();

    final initial = widget.initialExperience;

    _jobTitleController = TextEditingController(text: initial?.jobTitle ?? '');
    _companyController = TextEditingController(
      text: initial?.companyName ?? '',
    );
    _startDateController = TextEditingController(
      text: initial?.startDate ?? '',
    );
    _endDateController = TextEditingController(text: initial?.endDate ?? '');
    _descriptionController = TextEditingController(
      text: initial?.description ?? '',
    );
    _relatedSkillsController = TextEditingController(
      text: initial == null
          ? ''
          : ExperienceTechnologiesParser.join(initial.technologies),
    );

    _employmentType = ValueNotifier<String?>(initial?.employmentType);
    _startDate = ValueNotifier<DateTime?>(
      ProfileFormValidator.parseDate(initial?.startDate),
    );
    _endDate = ValueNotifier<DateTime?>(
      ProfileFormValidator.parseDate(initial?.endDate),
    );
    _isCurrent = ValueNotifier<bool>(initial?.isCurrent ?? false);

    _country = ValueNotifier<String?>(initial?.country);
    _state = ValueNotifier<String?>(null);
    _city = ValueNotifier<String?>(initial?.city);

    _stateOptions = ValueNotifier<Map<String, String>>(const {});
    _cityOptions = ValueNotifier<Map<String, String>>(const {});

    _loadStatesForCountry(_country.value);
    if (_country.value != null && _city.value != null) {
      _resolveStateForCity(_country.value, _city.value);
    }
  }

  Future<void> _loadStatesForCountry(String? countryName) async {
    final request = ++_statesRequest;
    final options = countryName == null
        ? const <String, String>{}
        : await _locationCatalog.statesForCountry(countryName);
    if (!mounted || request != _statesRequest) return;
    _stateOptions.value = options;
  }

  Future<void> _loadCitiesForState(
    String? countryName,
    String? stateName,
  ) async {
    final request = ++_citiesRequest;
    final options = countryName == null || stateName == null
        ? const <String, String>{}
        : await _locationCatalog.citiesForState(countryName, stateName);
    if (!mounted || request != _citiesRequest) return;
    _cityOptions.value = options;
  }

  /// Resolves the local-only state filter from saved country/city data
  /// so city options are scoped on entry. Never submitted.
  Future<void> _resolveStateForCity(
    String? countryName,
    String? cityName,
  ) async {
    if (countryName == null || cityName == null) return;
    final resolved = await _locationCatalog.resolveStateName(
      countryName,
      cityName,
    );
    if (!mounted) return;
    if (resolved == null || _state.value != null) return;
    _state.value = resolved;
    _loadCitiesForState(countryName, resolved);
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _companyController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _descriptionController.dispose();
    _relatedSkillsController.dispose();

    _employmentType.dispose();
    _startDate.dispose();
    _endDate.dispose();
    _isCurrent.dispose();
    _country.dispose();
    _state.dispose();
    _city.dispose();
    _stateOptions.dispose();
    _cityOptions.dispose();

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

  static bool _sameTechnologies(List<String> current, List<String> baseline) {
    if (current.length != baseline.length) return false;
    for (int i = 0; i < current.length; i++) {
      if (current[i] != baseline[i]) return false;
    }
    return true;
  }

  void _handleSave() {
    if (widget.isSaving) return;
    final locale = S.of(context);

    final jobTitle = _jobTitleController.text.trim();
    if (jobTitle.isEmpty) {
      _showMessage(locale.required);
      return;
    }

    final companyName = _companyController.text.trim();
    if (companyName.isEmpty) {
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
    final technologies = ExperienceTechnologiesParser.parse(
      _relatedSkillsController.text,
    );

    final baseline = widget.initialExperience;
    if (baseline == null) {
      widget.onAdd(
        AddExperienceParams(
          jobTitle: jobTitle,
          companyName: companyName,
          employmentType: _employmentType.value,
          country: _normalizedOrNull(_country.value ?? ''),
          city: _normalizedOrNull(_city.value ?? ''),
          description: _normalizedOrNull(_descriptionController.text),
          technologies: technologies,
          isCurrent: isCurrent,
          startDate: startText,
          endDate: endText,
        ),
      );
      return;
    }

    var params = UpdateExperienceParams(experienceId: baseline.id);

    if (jobTitle != baseline.jobTitle) {
      params = params.copyWith(experienceId: baseline.id, jobTitle: jobTitle);
    }

    if (companyName != baseline.companyName) {
      params = params.copyWith(
        experienceId: baseline.id,
        companyName: companyName,
      );
    }

    if (_employmentType.value != baseline.employmentType) {
      params = params.copyWith(
        experienceId: baseline.id,
        employmentType: _employmentType.value,
      );
    }

    final country = _normalizedOrNull(_country.value ?? '');
    if (country != _normalizedOrNull(baseline.country ?? '')) {
      params = params.copyWith(experienceId: baseline.id, country: country);
    }

    final city = _normalizedOrNull(_city.value ?? '');
    if (city != _normalizedOrNull(baseline.city ?? '')) {
      params = params.copyWith(experienceId: baseline.id, city: city);
    }

    final description = _normalizedOrNull(_descriptionController.text);
    if (description != baseline.description) {
      params = params.copyWith(
        experienceId: baseline.id,
        description: description,
      );
    }

    if (!_sameTechnologies(technologies, baseline.technologies)) {
      params = params.copyWith(
        experienceId: baseline.id,
        technologies: technologies,
      );
    }

    if (isCurrent != baseline.isCurrent) {
      params = params.copyWith(
        experienceId: baseline.id,
        isCurrent: isCurrent,
        // is_current=true requires end_date to be absent/null:
        // explicitly clear a previously stored end date.
        endDate: isCurrent ? null : endText,
      );
    } else {
      if (startText != baseline.startDate) {
        params = params.copyWith(
          experienceId: baseline.id,
          startDate: startText,
        );
      }
      if (!isCurrent && endText != baseline.endDate) {
        params = params.copyWith(experienceId: baseline.id, endDate: endText);
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

    // TODO(experience-backend): Backend acceptance of these underscore
    // machine values is pending runtime verification against Swagger
    // (the manual shows "full-time" while jobs payloads use "full_time").
    // Send the keys unchanged and rely on 422 field errors if rejected.
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
            _isEditing ? locale.editExperience : locale.addNewExperience,
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
                    // TODO(experience-backend):
                    // Enable Experience Work Mode when the backend
                    // provides a confirmed request/response contract.
                    child: ExperienceDropdownField(
                      label: locale.workMode,
                      value: null,
                      items: workModes,
                      enabled: false,
                      onChanged: (_) {},
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 18.h),
          ValueListenableBuilder<String?>(
            valueListenable: _country,
            builder: (context, country, child) {
              return ValueListenableBuilder<String?>(
                valueListenable: _state,
                builder: (context, state, child) {
                  return ValueListenableBuilder<String?>(
                    valueListenable: _city,
                    builder: (context, city, child) {
                      return ValueListenableBuilder<Map<String, String>>(
                        valueListenable: _stateOptions,
                        builder: (context, stateOptions, child) {
                          return ValueListenableBuilder<Map<String, String>>(
                            valueListenable: _cityOptions,
                            builder: (context, cityOptions, child) {
                              final arabic =
                                  Localizations.localeOf(context)
                                      .languageCode ==
                                  'ar';
                              final countries = _locationCatalog.countries(
                                arabic: arabic,
                              );
                              return Column(
                                children: [
                                  ExperienceDropdownField(
                                    label: locale.country,
                                    value: country,
                                    items: countries,
                                    onChanged: (value) {
                                      _country.value = value;
                                      _state.value = null;
                                      _city.value = null;
                                      _cityOptions.value = const {};
                                      _loadStatesForCountry(value);
                                    },
                                  ),
                                  SizedBox(height: 18.h),
                                  // Local-only filter for city options.
                                  // Experience has no state field, so this
                                  // value is never submitted.
                                  ExperienceDropdownField(
                                    label: locale.stateGovernorate,
                                    value: state,
                                    items: stateOptions,
                                    onChanged: (value) {
                                      _state.value = value;
                                      _city.value = null;
                                      _loadCitiesForState(
                                        _country.value,
                                        value,
                                      );
                                    },
                                  ),
                                  SizedBox(height: 18.h),
                                  ExperienceDropdownField(
                                    label: locale.city,
                                    value: city,
                                    items: cityOptions,
                                    onChanged: (value) {
                                      _city.value = value;
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
          SizedBox(height: 18.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ExperienceFormField(
                  label: locale.startDate,
                  controller: _startDateController,
                  hintText: locale.monthYearHint,
                  readOnly: true,
                  onTap: () => _pickDate(
                    notifier: _startDate,
                    controller: _startDateController,
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
                      child: ExperienceFormField(
                        label: locale.endDate,
                        controller: _endDateController,
                        hintText: locale.monthYearHint,
                        readOnly: true,
                        onTap: isCurrent
                            ? null
                            : () => _pickDate(
                                notifier: _endDate,
                                controller: _endDateController,
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
                  title: Text(locale.currentlyWorkHere),
                  onChanged: widget.isSaving
                      ? null
                      : (value) {
                          _isCurrent.value = value ?? false;

                          if (_isCurrent.value) {
                            _endDate.value = null;
                            _endDateController.clear();
                          }
                        },
                ),
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

          ExperienceFormField(
            label: locale.relatedSkills,
            controller: _relatedSkillsController,
            hintText: locale.relatedSkillsHint,
          ),

          SizedBox(height: 24.h),
          Divider(color: theme.dividerColor),
          SizedBox(height: 16.h),
          ExperienceFormActions(
            isSaving: widget.isSaving,
            onCancel: widget.onCancel,
            onSave: _handleSave,
          ),
        ],
      ),
    );
  }
}
