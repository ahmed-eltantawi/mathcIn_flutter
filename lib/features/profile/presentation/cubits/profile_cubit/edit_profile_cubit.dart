import 'dart:typed_data';

import 'package:MatchIn/features/profile/domain/entities/avatar_upload_input.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_profile_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_candidate_profile_params.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_candidate_profile_for_edit_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/update_candidate_profile_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/upload_avatar_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/profile_cubit/edit_profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit({
    required this._getCandidateProfileForEditUseCase,
    required this._updateCandidateProfileUseCase,
    required this._uploadAvatarUseCase,
  }) : super(const EditProfileInitial());

  final GetCandidateProfileForEditUseCase _getCandidateProfileForEditUseCase;

  final UpdateCandidateProfileUseCase _updateCandidateProfileUseCase;

  final UploadAvatarUseCase _uploadAvatarUseCase;

  Future<void> loadProfile() async {
    emit(const EditProfileLoading());

    final result = await _getCandidateProfileForEditUseCase();
    if (isClosed) return;

    result.fold(
      (failure) {
        emit(EditProfileLoadFailure(failure.message));
      },
      (profile) {
        emit(EditProfileReady(profile));
      },
    );
  }

  Future<void> updateProfile(UpdateCandidateProfileParams params) async {
    // Never send an empty PATCH: callers must diff first and skip
    // the request when nothing changed.
    if (!params.hasChanges) return;

    final currentState = state;
    if (currentState is EditProfileSaving) return;

    final CandidateProfileEntity? baseline = switch (currentState) {
      EditProfileReady(profile: final profile) => profile,
      EditProfileActionFailure(profile: final profile) => profile,
      EditProfileAvatarStaged(profile: final profile) => profile,
      EditProfileSaving(profile: final profile) => profile,
      _ => null,
    };
    if (baseline == null) return;

    emit(EditProfileSaving(baseline));

    final result = await _updateCandidateProfileUseCase(params);
    if (isClosed) return;

    result.fold(
      (failure) {
        emit(EditProfileActionFailure(failure.message, profile: baseline));
      },
      (profile) {
        emit(EditProfileSuccess(profile));
      },
    );
  }

  /// Stages a validated picked image for preview. The staged bytes live
  /// in state only; nothing is persisted and the baseline avatar is
  /// untouched. Replaces any previous staged preview.
  Future<void> stageAvatar({
    required Uint8List avatarBytes,
    required String fileName,
  }) async {
    if (state is EditProfileSaving) return;

    final CandidateProfileEntity? baseline = switch (state) {
      EditProfileReady(profile: final profile) => profile,
      EditProfileActionFailure(profile: final profile) => profile,
      EditProfileAvatarStaged(profile: final profile) => profile,
      _ => null,
    };
    if (baseline == null || avatarBytes.isEmpty) return;
    if (isClosed) return;

    emit(
      EditProfileAvatarStaged(
        baseline,
        avatarBytes: avatarBytes,
        fileName: fileName,
      ),
    );
  }

  /// Discards the staged preview and returns to the loaded profile.
  /// The existing avatar is preserved.
  void clearStagedAvatar() {
    final currentState = state;
    if (currentState is! EditProfileAvatarStaged) return;
    if (isClosed) return;

    emit(EditProfileReady(currentState.profile));
  }

  /// Attempts to upload the staged avatar through [UploadAvatarUseCase].
  ///
  /// TODO(avatar-backend): the remote endpoint is unimplemented, so this
  /// currently surfaces pending-backend feedback and preserves the
  /// baseline avatar. Never fabricates upload success.
  Future<void> confirmAvatarUpload() async {
    final currentState = state;
    if (currentState is! EditProfileAvatarStaged) return;
    if (isClosed) return;

    final result = await _uploadAvatarUseCase(
      AvatarUploadInput(
        fileName: currentState.fileName,
        bytes: currentState.avatarBytes,
      ),
    );
    if (isClosed) return;

    result.fold(
      (failure) {
        emit(
          EditProfileActionFailure(
            failure.message,
            profile: currentState.profile,
          ),
        );
      },
      (_) {
        // TODO(avatar-backend): unreachable until the endpoint lands.
        // Handle real upload success (refresh + pop) only then.
        emit(
          EditProfileActionFailure(
            'Avatar upload is not available yet.',
            profile: currentState.profile,
          ),
        );
      },
    );
  }
}
