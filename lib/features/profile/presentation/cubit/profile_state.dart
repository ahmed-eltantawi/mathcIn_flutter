import 'package:MatchIn/features/profile/domain/entities/user_profile_entity.dart';
import 'package:equatable/equatable.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded({
    required this.userProfile,
    this.isFromCache = false,
  });

  final UserProfileEntity userProfile;
  final bool isFromCache;

  @override
  List<Object?> get props => [userProfile, isFromCache];
}

final class ProfileError extends ProfileState {
  const ProfileError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
