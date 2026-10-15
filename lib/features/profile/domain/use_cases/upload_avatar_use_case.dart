import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/avatar_upload_input.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class UploadAvatarUseCase {
  const UploadAvatarUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<Failure, Unit>> call(AvatarUploadInput input) {
    return repository.uploadAvatar(input);
  }
}
