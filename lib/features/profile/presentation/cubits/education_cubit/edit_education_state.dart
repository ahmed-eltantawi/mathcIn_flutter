import 'package:MatchIn/features/profile/domain/entities/education_entity.dart';
import 'package:equatable/equatable.dart';

sealed class EditEducationState extends Equatable {
  const EditEducationState();

  @override
  List<Object?> get props => [];
}

final class EditEducationInitial extends EditEducationState {
  const EditEducationInitial();
}

final class EditEducationLoading extends EditEducationState {
  const EditEducationLoading();
}

final class EditEducationSuccess extends EditEducationState {
  const EditEducationSuccess({
    required this.educations,
    this.editingEducation,
    this.formResetToken = 0,
  });

  final List<EducationEntity> educations;
  final EducationEntity? editingEducation;
  final int formResetToken;

  bool get isEditing => editingEducation != null;

  @override
  List<Object?> get props => [educations, editingEducation, formResetToken];
}

final class EditEducationSaving extends EditEducationState {
  const EditEducationSaving({
    required this.educations,
    this.editingEducation,
    this.formResetToken = 0,
  });

  final List<EducationEntity> educations;
  final EducationEntity? editingEducation;
  final int formResetToken;

  @override
  List<Object?> get props => [educations, editingEducation, formResetToken];
}

final class EditEducationFailure extends EditEducationState {
  const EditEducationFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class EditEducationActionFailure extends EditEducationState {
  const EditEducationActionFailure({
    required this.educations,
    required this.message,
    this.editingEducation,
    this.formResetToken = 0,
  });

  final List<EducationEntity> educations;
  final String message;
  final EducationEntity? editingEducation;
  final int formResetToken;

  @override
  List<Object?> get props => [
    educations,
    message,
    editingEducation,
    formResetToken,
  ];
}
