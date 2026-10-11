import 'package:MatchIn/features/profile/domain/entities/career_preference_entity.dart';
import 'package:equatable/equatable.dart';

sealed class CareerPreferencesState extends Equatable {
  const CareerPreferencesState();

  @override
  List<Object?> get props => [];
}

final class CareerPreferencesInitial extends CareerPreferencesState {
  const CareerPreferencesInitial();
}

final class CareerPreferencesLoading extends CareerPreferencesState {
  const CareerPreferencesLoading();
}

final class CareerPreferencesSuccess extends CareerPreferencesState {
  const CareerPreferencesSuccess({required this.preferences});

  final CareerPreferenceEntity? preferences;

  @override
  List<Object?> get props => [preferences];
}

final class CareerPreferencesSaving extends CareerPreferencesState {
  const CareerPreferencesSaving({required this.preferences});

  final CareerPreferenceEntity? preferences;

  @override
  List<Object?> get props => [preferences];
}

final class CareerPreferencesSaveSuccess extends CareerPreferencesState {
  const CareerPreferencesSaveSuccess({required this.preferences});

  final CareerPreferenceEntity preferences;

  @override
  List<Object?> get props => [preferences];
}

final class CareerPreferencesFailure extends CareerPreferencesState {
  const CareerPreferencesFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class CareerPreferencesActionFailure extends CareerPreferencesState {
  const CareerPreferencesActionFailure({
    required this.preferences,
    required this.message,
  });

  final CareerPreferenceEntity? preferences;
  final String message;

  @override
  List<Object?> get props => [preferences, message];
}
