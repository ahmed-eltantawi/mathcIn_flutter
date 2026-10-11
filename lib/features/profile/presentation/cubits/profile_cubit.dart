import 'package:MatchIn/features/profile/domain/use_cases/get_candidate_profile_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_cached_candidate_profile_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this.getCandidateProfileUseCase,
    required this.getCachedCandidateProfileUseCase,
  }) : super(const ProfileInitial());

  final GetCandidateProfileUseCase getCandidateProfileUseCase;
  final GetCachedCandidateProfileUseCase getCachedCandidateProfileUseCase;

  Future<void> getCandidateProfile() async {
    emit(const ProfileLoading());

    final result = await getCandidateProfileUseCase();

    result.fold(
      (failure) {
        emit(ProfileFailure(message: failure.message));
      },
      (profile) {
        emit(ProfileSuccess(profile: profile));
      },
    );
  }
}
