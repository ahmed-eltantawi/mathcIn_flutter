import 'package:MatchIn/features/profile/domain/entities/candidate_profile_entity.dart';
import 'package:equatable/equatable.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileSuccess extends ProfileState {
  const ProfileSuccess({required this.profile});

  final CandidateProfileEntity profile;

  @override
  List<Object?> get props => [profile];
}

final class ProfileFailure extends ProfileState {
  const ProfileFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
