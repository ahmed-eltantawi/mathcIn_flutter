import 'package:MatchIn/features/profile/domain/entities/experience_entity.dart';
import 'package:equatable/equatable.dart';

sealed class EditExperienceState extends Equatable {
  const EditExperienceState();

  @override
  List<Object?> get props => [];
}

final class EditExperienceInitial extends EditExperienceState {
  const EditExperienceInitial();
}

final class EditExperienceLoading extends EditExperienceState {
  const EditExperienceLoading();
}

final class EditExperienceSuccess extends EditExperienceState {
  const EditExperienceSuccess({
    required this.experiences,
    this.editingExperience,
    this.formResetToken = 0,
  });

  final List<ExperienceEntity> experiences;
  final ExperienceEntity? editingExperience;
  final int formResetToken;

  bool get isEditing => editingExperience != null;

  @override
  List<Object?> get props => [experiences, editingExperience, formResetToken];
}

final class EditExperienceSaving extends EditExperienceState {
  const EditExperienceSaving({
    required this.experiences,
    this.editingExperience,
    this.formResetToken = 0,
  });

  final List<ExperienceEntity> experiences;
  final ExperienceEntity? editingExperience;
  final int formResetToken;

  @override
  List<Object?> get props => [experiences, editingExperience, formResetToken];
}

final class EditExperienceFailure extends EditExperienceState {
  const EditExperienceFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class EditExperienceActionFailure extends EditExperienceState {
  const EditExperienceActionFailure({
    required this.experiences,
    required this.message,
    this.editingExperience,
    this.formResetToken = 0,
  });

  final List<ExperienceEntity> experiences;
  final String message;
  final ExperienceEntity? editingExperience;
  final int formResetToken;

  @override
  List<Object?> get props => [
    experiences,
    message,
    editingExperience,
    formResetToken,
  ];
}
