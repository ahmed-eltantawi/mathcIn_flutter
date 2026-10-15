import 'package:MatchIn/features/profile/domain/entities/add_education_params.dart';
import 'package:MatchIn/features/profile/domain/entities/education_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_education_params.dart';
import 'package:MatchIn/features/profile/domain/use_cases/add_education_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/delete_education_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_educations_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/update_education_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/education_cubit/edit_education_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditEducationCubit extends Cubit<EditEducationState> {
  EditEducationCubit({
    required this.getEducationsUseCase,
    required this.addEducationUseCase,
    required this.updateEducationUseCase,
    required this.deleteEducationUseCase,
  }) : super(const EditEducationInitial());

  final GetEducationsUseCase getEducationsUseCase;
  final AddEducationUseCase addEducationUseCase;
  final UpdateEducationUseCase updateEducationUseCase;
  final DeleteEducationUseCase deleteEducationUseCase;

  List<EducationEntity> _educations = [];
  EducationEntity? _editing;
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
      EditEducationSuccess(
        educations: List.unmodifiable(_educations),
        editingEducation: _editing,
        formResetToken: _formResetToken,
      ),
    );
  }

  void _emitSaving() {
    emit(
      EditEducationSaving(
        educations: List.unmodifiable(_educations),
        editingEducation: _editing,
        formResetToken: _formResetToken,
      ),
    );
  }

  void _emitActionFailure(String message) {
    emit(
      EditEducationActionFailure(
        educations: List.unmodifiable(_educations),
        message: message,
        editingEducation: _editing,
        formResetToken: _formResetToken,
      ),
    );
  }

  Future<void> loadEducations() async {
    emit(const EditEducationLoading());

    final result = await getEducationsUseCase();
    if (isClosed) return;

    result.fold(
      (failure) {
        emit(EditEducationFailure(message: failure.message));
      },
      (educations) {
        _educations = _sorted(educations);
        _editing = null;
        _emitSuccess();
      },
    );
  }

  void startEdit(EducationEntity education) {
    if (state is EditEducationSaving) return;
    _editing = education;
    _formResetToken++;
    _emitSuccess();
  }

  void cancelEdit() {
    if (state is EditEducationSaving) return;
    _editing = null;
    _formResetToken++;
    _emitSuccess();
  }

  Future<void> addEducation(AddEducationParams params) async {
    if (state is EditEducationSaving) return;
    _emitSaving();

    final result = await addEducationUseCase(params);
    if (isClosed) return;

    result.fold(
      (failure) {
        _emitActionFailure(failure.message);
      },
      (education) {
        if (education == null) {
          _refreshAfterMutation();
          return;
        }
        _educations = _sorted([..._educations, education]);
        _editing = null;
        _formResetToken++;
        _hasChanges = true;
        _lastMutationWasDelete = false;
        _emitSuccess();
      },
    );
  }

  Future<void> updateEducation(UpdateEducationParams params) async {
    if (state is EditEducationSaving) return;
    _emitSaving();

    final result = await updateEducationUseCase(params);
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
        _educations = _sorted(
          _educations
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

  /// Reloads the authoritative list when a mutation succeeded but its
  /// response payload was incomplete. The existing list is preserved on
  /// refresh failure, while [_hasChanges] stays true because the server
  /// already applied the mutation.
  Future<void> _refreshAfterMutation() async {
    final result = await getEducationsUseCase();
    if (isClosed) return;

    result.fold(
      (failure) {
        _hasChanges = true;
        _emitActionFailure(failure.message);
      },
      (educations) {
        _educations = _sorted(educations);
        _editing = null;
        _formResetToken++;
        _hasChanges = true;
        _lastMutationWasDelete = false;
        _emitSuccess();
      },
    );
  }

  Future<void> deleteEducation(int educationId) async {
    if (state is EditEducationSaving) return;
    _emitSaving();

    final result = await deleteEducationUseCase(educationId);
    if (isClosed) return;

    result.fold(
      (failure) {
        _emitActionFailure(failure.message);
      },
      (_) {
        _educations = _educations
            .where((item) => item.id != educationId)
            .toList();
        if (_editing?.id == educationId) {
          _editing = null;
          _formResetToken++;
        }
        _hasChanges = true;
        _lastMutationWasDelete = true;
        _emitSuccess();
      },
    );
  }

  static List<EducationEntity> _sorted(List<EducationEntity> items) {
    final sorted = List<EducationEntity>.of(items);
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
