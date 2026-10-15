import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/profile/data/data_sources/location/location_catalog.dart';
import 'package:MatchIn/features/profile/domain/entities/career_preference_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/save_career_preferences_params.dart';
import 'package:MatchIn/features/profile/presentation/cubits/career_cubit/career_preferences_cubit.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/career_goal_section.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/career_preferences_actions.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/experience_level_section.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/job_type_section.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/preference_options_sheet.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/preferred_location_section.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/target_role_section.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/work_mode_section.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CareerPreferencesForm extends StatefulWidget {
  const CareerPreferencesForm({
    required this.preferences,
    this.isSaving = false,
    super.key,
  });

  final CareerPreferenceEntity? preferences;
  final bool isSaving;

  @override
  State<CareerPreferencesForm> createState() => _CareerPreferencesFormState();
}

class _CareerPreferencesFormState extends State<CareerPreferencesForm> {
  late final TextEditingController _targetRoleController;
  late final TextEditingController _careerGoalController;

  late final ValueNotifier<String?> _experienceLevel;
  late final ValueNotifier<String?> _jobType;
  late final ValueNotifier<String?> _workMode;

  late final ValueNotifier<String> _country;
  late final ValueNotifier<String> _state;
  late final ValueNotifier<String> _city;

  late final ValueNotifier<bool> _openToRelocation;

  late final ValueNotifier<Map<String, String>> _stateOptions;
  late final ValueNotifier<Map<String, String>> _cityOptions;

  int _statesRequest = 0;
  int _citiesRequest = 0;

  LocationCatalog get _locationCatalog => getIt<LocationCatalog>();

  @override
  void initState() {
    super.initState();

    final preferences = widget.preferences;

    _targetRoleController = TextEditingController(
      text: preferences?.targetRole ?? '',
    );

    _careerGoalController = TextEditingController(
      text: preferences?.careerGoal ?? '',
    );

    _experienceLevel = ValueNotifier(preferences?.experienceLevel);

    _jobType = ValueNotifier(preferences?.jobType);

    _workMode = ValueNotifier(preferences?.workMode);

    _country = ValueNotifier(preferences?.preferredCountry ?? '');

    _state = ValueNotifier('');

    _city = ValueNotifier(preferences?.preferredCity ?? '');

    _openToRelocation = ValueNotifier(preferences?.openToRelocation ?? false);

    _stateOptions = ValueNotifier<Map<String, String>>(const {});
    _cityOptions = ValueNotifier<Map<String, String>>(const {});

    _loadStatesForCountry(_country.value);
    if (_country.value.isNotEmpty && _city.value.isNotEmpty) {
      _resolveStateForCity(_country.value, _city.value);
    }
  }

  /// Loads state options for [countryName] from the local dataset.
  ///
  /// Stale responses from superseded requests are discarded.
  Future<void> _loadStatesForCountry(String countryName) async {
    final request = ++_statesRequest;
    final options = countryName.isEmpty
        ? const <String, String>{}
        : await _locationCatalog.statesForCountry(countryName);
    if (!mounted || request != _statesRequest) return;
    _stateOptions.value = options;
  }

  /// Loads city options for [stateName] in [countryName].
  Future<void> _loadCitiesForState(String countryName, String stateName) async {
    final request = ++_citiesRequest;
    final options = countryName.isEmpty || stateName.isEmpty
        ? const <String, String>{}
        : await _locationCatalog.citiesForState(countryName, stateName);
    if (!mounted || request != _citiesRequest) return;
    _cityOptions.value = options;
  }

  /// Resolves the local-only state filter from saved country/city data
  /// so city options are scoped on entry. The state value itself is
  /// never submitted: the API has no preferred_state.
  Future<void> _resolveStateForCity(String countryName, String cityName) async {
    final resolved = await _locationCatalog.resolveStateName(
      countryName,
      cityName,
    );
    if (!mounted) return;
    if (resolved == null || _state.value.isNotEmpty) return;
    _state.value = resolved;
    _loadCitiesForState(countryName, resolved);
  }

  /// Opens the country picker sheet. Clearing dependents keeps city
  /// options consistent with the selected country.
  Future<void> _pickCountry() async {
    if (widget.isSaving) return;
    final locale = S.of(context);
    final countries = _locationCatalog.countries(
      arabic: Localizations.localeOf(context).languageCode == 'ar',
    );
    final options = [...countries.keys];
    if (_country.value.isNotEmpty && !options.contains(_country.value)) {
      options.insert(0, _country.value);
    }
    final picked = await PreferenceOptionsSheet.show(
      context,
      title: locale.country,
      options: options,
      selected: _country.value.isEmpty ? null : _country.value,
    );
    if (picked == null || !mounted) return;
    _country.value = picked;
    _state.value = '';
    _city.value = '';
    _cityOptions.value = const {};
    _loadStatesForCountry(picked);
  }

  /// Opens the state picker sheet. State is a local-only filter for
  /// cities and is never submitted.
  Future<void> _pickState() async {
    if (widget.isSaving) return;
    if (_stateOptions.value.isEmpty && _country.value.isNotEmpty) {
      await _loadStatesForCountry(_country.value);
      if (!mounted) return;
    }
    if (!mounted) return;
    final locale = S.of(context);
    final options = [..._stateOptions.value.keys];
    if (_state.value.isNotEmpty && !options.contains(_state.value)) {
      options.insert(0, _state.value);
    }
    final picked = await PreferenceOptionsSheet.show(
      context,
      title: locale.stateGovernorate,
      options: options,
      selected: _state.value.isEmpty ? null : _state.value,
    );
    if (picked == null || !mounted) return;
    _state.value = picked;
    _city.value = '';
    _loadCitiesForState(_country.value, picked);
  }

  /// Opens the city picker sheet scoped to the selected state.
  Future<void> _pickCity() async {
    if (widget.isSaving) return;
    if (_cityOptions.value.isEmpty &&
        _country.value.isNotEmpty &&
        _state.value.isNotEmpty) {
      await _loadCitiesForState(_country.value, _state.value);
      if (!mounted) return;
    }
    if (!mounted) return;
    final locale = S.of(context);
    final options = [..._cityOptions.value.keys];
    if (_city.value.isNotEmpty && !options.contains(_city.value)) {
      options.insert(0, _city.value);
    }
    final picked = await PreferenceOptionsSheet.show(
      context,
      title: locale.city,
      options: options,
      selected: _city.value.isEmpty ? null : _city.value,
    );
    if (picked == null || !mounted) return;
    _city.value = picked;
  }

  @override
  void dispose() {
    _targetRoleController.dispose();
    _careerGoalController.dispose();

    _experienceLevel.dispose();
    _jobType.dispose();
    _workMode.dispose();

    _country.dispose();
    _state.dispose();
    _city.dispose();

    _openToRelocation.dispose();

    _stateOptions.dispose();
    _cityOptions.dispose();

    super.dispose();
  }

  void _save() {
    if (widget.isSaving) return;
    final baseline = widget.preferences;

    var params = const SaveCareerPreferencesParams();

    final targetRole = _nullableText(_targetRoleController.text);
    if (targetRole != baseline?.targetRole) {
      params = params.copyWith(targetRole: targetRole);
    }

    if (_jobType.value != baseline?.jobType) {
      params = params.copyWith(jobType: _jobType.value);
    }

    if (_workMode.value != baseline?.workMode) {
      params = params.copyWith(workMode: _workMode.value);
    }

    final country = _nullableText(_country.value);
    if (country != baseline?.preferredCountry) {
      params = params.copyWith(preferredCountry: country);
    }

    final city = _nullableText(_city.value);
    if (city != baseline?.preferredCity) {
      params = params.copyWith(preferredCity: city);
    }

    if (_experienceLevel.value != baseline?.experienceLevel) {
      params = params.copyWith(experienceLevel: _experienceLevel.value);
    }

    final careerGoal = _nullableText(_careerGoalController.text);
    if (careerGoal != baseline?.careerGoal) {
      params = params.copyWith(careerGoal: careerGoal);
    }

    if (_openToRelocation.value != (baseline?.openToRelocation ?? false)) {
      params = params.copyWith(openToRelocation: _openToRelocation.value);
    }

    // No PATCH when nothing changed: avoids an empty request body
    // and keeps the form exactly as the user left it.
    if (!params.hasChanges) return;

    context.read<CareerPreferencesCubit>().saveCareerPreferences(params);
  }

  String? _nullableText(String value) {
    final trimmed = value.trim();

    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TargetRoleSection(
          controller: _targetRoleController,

          // No roles suggestion endpoint confirmed yet.
          suggestedRoles: const [],
          selectedSuggestedRole: null,

          onRoleChanged: (_) {},
          onClear: _targetRoleController.clear,
          onSuggestedRolePressed: (role) {
            _targetRoleController.text = role;
          },
        ),

        SizedBox(height: 16.h),

        ValueListenableBuilder<String?>(
          valueListenable: _experienceLevel,
          builder: (context, value, _) {
            return ExperienceLevelSection(
              selectedLevel: value,
              onSelected: (level) {
                _experienceLevel.value = level;
              },
            );
          },
        ),

        SizedBox(height: 16.h),

        ValueListenableBuilder<String?>(
          valueListenable: _jobType,
          builder: (context, value, _) {
            return JobTypeSection(
              selectedType: value,
              onSelected: (type) {
                _jobType.value = type;
              },
            );
          },
        ),

        SizedBox(height: 16.h),

        ValueListenableBuilder<String?>(
          valueListenable: _workMode,
          builder: (context, value, _) {
            return WorkModeSection(
              selectedMode: value,
              onSelected: (mode) {
                _workMode.value = mode;
              },
            );
          },
        ),

        SizedBox(height: 16.h),

        ListenableBuilder(
          listenable: Listenable.merge([
            _country,
            _state,
            _city,
            _openToRelocation,
          ]),
          builder: (context, _) {
            return PreferredLocationSection(
              country: _country.value,
              state: _state.value,
              city: _city.value,
              openToRelocation: _openToRelocation.value,

              // Country/City come from the local dataset; State stays
              // a local-only filter (no preferred_state in the API).
              onCountryPressed: _pickCountry,
              onStatePressed: _pickState,
              onCityPressed: _pickCity,

              onOpenToRelocationChanged: (value) {
                if (value == null) return;

                _openToRelocation.value = value;
              },
            );
          },
        ),

        SizedBox(height: 16.h),

        CareerGoalSection(controller: _careerGoalController),

        SizedBox(height: 28.h),

        CareerPreferencesActions(
          isSaving: widget.isSaving,
          onSavePressed: _save,
          onCancelPressed: () =>
              Navigator.of(context)
                  .pop(context.read<CareerPreferencesCubit>().hasChanges),
        ),
      ],
    );
  }
}
