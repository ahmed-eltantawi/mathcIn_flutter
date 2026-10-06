import 'package:MatchIn/features/profile/domain/use_cases/get_user_profile_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubit/profile_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required this.getUserProfileUseCase,
    Object? getCandidateProfileUseCase,
    Object? getCachedCandidateProfileUseCase,
  }) : super(ProfileInitial());

  final GetUserProfileUseCase getUserProfileUseCase;

  Future<void> fetchUserProfile() async {
    emit(ProfileLoading());
    final result = await getUserProfileUseCase();
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(userProfile: profile)),
    );
  }
}
