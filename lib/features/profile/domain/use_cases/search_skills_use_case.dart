import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/skill_search_result_entity.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:dartz/dartz.dart';

class SearchSkillsUseCase {
  const SearchSkillsUseCase({required this.repository});

  final ProfileRepository repository;

  Future<Either<Failure, List<SkillSearchResultEntity>>> call(String query) {
    return repository.searchSkills(query);
  }
}
