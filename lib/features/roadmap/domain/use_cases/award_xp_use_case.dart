import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/roadmap/domain/entities/award_xp_params.dart';
import 'package:MatchIn/features/roadmap/domain/entities/award_xp_response_entity.dart';
import 'package:MatchIn/features/roadmap/domain/repositories/roadmap_repository.dart';
import 'package:dartz/dartz.dart';

/// Awards XP through the canonical `PATCH /roadmaps/xp` route.
///
/// [opKey] is the stable deduplication key (e.g. one per treasure
/// milestone) so retries and restarts never award the same reward twice.
/// Offline the op is queued durably and an [OfflineFailure] is returned —
/// callers must not treat that as confirmed XP.
class AwardXpUseCase {
  const AwardXpUseCase({required this.repository});

  final RoadmapRepository repository;

  Future<Either<Failure, AwardXpResponseEntity>> call(
    AwardXpParams params, {
    required String opKey,
  }) {
    return repository.awardXp(params, opKey: opKey);
  }
}
