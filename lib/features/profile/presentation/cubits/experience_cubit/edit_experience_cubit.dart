import 'package:MatchIn/features/profile/domain/entities/add_experience_params.dart';
import 'package:MatchIn/features/profile/domain/entities/experience_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_experience_params.dart';
import 'package:MatchIn/features/profile/domain/use_cases/add_experience_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/delete_experience_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_experiences_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/update_experience_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/experience_cubit/edit_experience_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditExperienceCubit extends Cubit<EditExperienceState> {
  EditExperienceCubit({
    required this.getExperiencesUseCase,
    required this.addExperienceUseCase,
    required this.updateExperienceUseCase,
    required this.deleteExperienceUseCase,
  }) : super(const EditExperienceInitial());

  final GetExperiencesUseCase getExperiencesUseCase;
  final AddExperienceUseCase addExperienceUseCase;
  final UpdateExperienceUseCase updateExperienceUseCase;
  final DeleteExperienceUseCase deleteExperienceUseCase;

  List<ExperienceEntity> _experiences = [];
  ExperienceEntity? _editing;
  int _formResetToken = 0;

  /// Sticky session flag: once any Add/Edit/Delete succeeds it stays
  /// true until the screen is closed. Cancel never resets it.
  bool _hasChanges = false;

  bool get hasChanges => _hasChanges;

  /// True when the most recent successful mutation was a delete,
  /// so the UI can show the matching localized feedback.
  bool _lastMutationWasDelete = false;

  bool get lastMutationWasDelete => _lastMutationWasDelete;

  void _emitSuccess() {
    emit(
      EditExperienceSuccess(
        experiences: List.unmodifiable(_experiences),
        editingExperience: _editing,
        formResetToken: _formResetToken,
      ),
    );
  }

  void _emitSaving() {
    emit(
      EditExperienceSaving(
        experiences: List.unmodifiable(_experiences),
        editingExperience: _editing,
        formResetToken: _formResetToken,
      ),
    );
  }

  void _emitActionFailure(String message) {
    emit(
      EditExperienceActionFailure(
        experiences: List.unmodifiable(_experiences),
        message: message,
        editingExperience: _editing,
        formResetToken: _formResetToken,
      ),
    );
  }

  Future<void> loadExperiences() async {
    emit(const EditExperienceLoading());

    final result = await getExperiencesUseCase();
    if (isClosed) return;

    result.fold(
      (failure) {
        emit(EditExperienceFailure(message: failure.message));
      },
      (experiences) {
        _experiences = _sorted(experiences);
        _editing = null;
        _emitSuccess();
      },
    );
  }

  void startEdit(ExperienceEntity experience) {
    if (state is EditExperienceSaving) return;
    _editing = experience;
    _formResetToken++;
    _emitSuccess();
  }

  void cancelEdit() {
    if (state is EditExperienceSaving) return;
    _editing = null;
    _formResetToken++;
    _emitSuccess();
  }

  Future<void> addExperience(AddExperienceParams params) async {
    if (state is EditExperienceSaving) return;
    _emitSaving();

    final result = await addExperienceUseCase(params);
    if (isClosed) return;

    result.fold(
      (failure) {
        _emitActionFailure(failure.message);
      },
      (experience) {
        if (experience == null) {
          _refreshAfterMutation();
          return;
        }
        _experiences = _sorted([..._experiences, experience]);
        _editing = null;
        _formResetToken++;
        _hasChanges = true;
        _lastMutationWasDelete = false;
        _emitSuccess();
      },
    );
  }

  Future<void> updateExperience(UpdateExperienceParams params) async {
    if (state is EditExperienceSaving) return;
    _emitSaving();

    final result = await updateExperienceUseCase(params);
    if (isClosed) return;

    result.fold(
      (failure) {
        _emitActionFailure(failure.message);
      },
      (updated) {
        if (updated == null) {
          _refreshAfterMutation();
          return;
        }
        _experiences = _sorted(
          _experiences
              .map((item) => item.id == updated.id ? updated : item)
              .toList(),
        );
        _editing = null;
        _formResetToken++;
        _hasChanges = true;
        _lastMutationWasDelete = false;
        _emitSuccess();
      },
    );
  }

  Future<void> deleteExperience(int experienceId) async {
    if (state is EditExperienceSaving) return;
    _emitSaving();

    final result = await deleteExperienceUseCase(experienceId);
    if (isClosed) return;

    result.fold(
      (failure) {
        _emitActionFailure(failure.message);
      },
      (_) {
        _experiences = _experiences
            .where((item) => item.id != experienceId)
            .toList();
        if (_editing?.id == experienceId) {
          _editing = null;
          _formResetToken++;
        }
        _hasChanges = true;
        _lastMutationWasDelete = true;
        _emitSuccess();
      },
    );
  }

  /// Reloads the authoritative list when a mutation succeeded but its
  /// response payload was incomplete. The existing list is preserved on
  /// refresh failure, while [_hasChanges] stays true because the server
  /// already applied the mutation.
  Future<void> _refreshAfterMutation() async {
    final result = await getExperiencesUseCase();
    if (isClosed) return;

    result.fold(
      (failure) {
        _hasChanges = true;
        _emitActionFailure(failure.message);
      },
      (experiences) {
        _experiences = _sorted(experiences);
        _editing = null;
        _formResetToken++;
        _hasChanges = true;
        _lastMutationWasDelete = false;
        _emitSuccess();
      },
    );
  }

  static List<ExperienceEntity> _sorted(List<ExperienceEntity> items) {
    final sorted = List<ExperienceEntity>.of(items);
    sorted.sort((a, b) {
      final dateComparison = _compareStartDates(b.startDate, a.startDate);
      if (dateComparison != 0) return dateComparison;
      return b.id.compareTo(a.id);
    });
    return sorted;
  }

  static int _compareStartDates(String? a, String? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return a.compareTo(b);
  }
}
