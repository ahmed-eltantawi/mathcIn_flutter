import 'package:MatchIn/features/profile/domain/entities/career_preference_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/save_career_preferences_params.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_career_preferences_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/save_career_preferences_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/career_preferences_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CareerPreferencesCubit extends Cubit<CareerPreferencesState> {
  CareerPreferencesCubit({
    required this.getCareerPreferencesUseCase,
    required this.saveCareerPreferencesUseCase,
  }) : super(const CareerPreferencesInitial());

  final GetCareerPreferencesUseCase getCareerPreferencesUseCase;

  final SaveCareerPreferencesUseCase saveCareerPreferencesUseCase;

  CareerPreferenceEntity? _preferences;

  Future<void> getCareerPreferences() async {
    emit(const CareerPreferencesLoading());

    final result = await getCareerPreferencesUseCase();

    result.fold(
      (failure) {
        emit(CareerPreferencesFailure(message: failure.message));
      },
      (preferences) {
        _preferences = preferences;

        emit(CareerPreferencesSuccess(preferences: _preferences));
      },
    );
  }

  Future<void> saveCareerPreferences(SaveCareerPreferencesParams params) async {
    emit(CareerPreferencesSaving(preferences: _preferences));

    final result = await saveCareerPreferencesUseCase(params);

    result.fold(
      (failure) {
        emit(
          CareerPreferencesActionFailure(
            preferences: _preferences,
            message: failure.message,
          ),
        );
      },
      (preferences) {
        _preferences = preferences;

        emit(CareerPreferencesSaveSuccess(preferences: preferences));
      },
    );
  }
}
