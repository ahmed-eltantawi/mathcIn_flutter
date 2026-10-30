import 'package:MatchIn/features/profile/domain/entities/candidate_profile_entity.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_candidate_profile_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_cached_candidate_profile_use_case.dart';

import 'profile_state.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this.getCandidateProfileUseCase,
    required this.getCachedCandidateProfileUseCase,
  }) : super(const ProfileInitial());

  final GetCandidateProfileUseCase getCandidateProfileUseCase;
  final GetCachedCandidateProfileUseCase getCachedCandidateProfileUseCase;

  int _loadGeneration = 0;

  /// Publishes a successfully saved profile so every screen using this
  /// app-scoped Cubit sees the same fresh model without waiting for a refetch.
  void publishProfile(CandidateProfileEntity profile) {
    if (isClosed) return;
    _loadGeneration++;
    emit(ProfileSuccess(profile: profile));
  }

  Future<void> getCandidateProfile() async {
    final generation = ++_loadGeneration;
    CandidateProfileEntity? cachedProfile;

    // 1. Emit cached profile immediately when available (offline-first).
    final cachedResult = await getCachedCandidateProfileUseCase();
    if (isClosed || generation != _loadGeneration) return;
    cachedResult.fold((_) => null, (profile) {
      if (profile != null) {
        cachedProfile = profile;
        emit(ProfileSuccess(profile: profile, isRefreshing: true));
      }
    });

    if (cachedProfile == null) {
      emit(const ProfileLoading());
    }

    // 2. Refresh from remote in the background; preserve cache on failure.
    final result = await getCandidateProfileUseCase();
    if (isClosed || generation != _loadGeneration) return;

    result.fold(
      (failure) {
        if (cachedProfile != null) {
          emit(ProfileSuccess(profile: cachedProfile!, isRefreshing: false));
        } else {
          emit(ProfileFailure(message: failure.message));
        }
      },
      (profile) {
        emit(ProfileSuccess(profile: profile, isRefreshing: false));
      },
    );
  }
}
