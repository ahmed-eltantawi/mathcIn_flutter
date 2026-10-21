import 'package:MatchIn/features/saved/domain/entities/saved_jobs_sync_report.dart';
import 'package:MatchIn/features/saved/domain/repositories/saved_jobs_repository.dart';

/// Replays due durable save/unsave ops in order. Safe on every reconnect,
/// foreground return, and manual retry: synchronized ops are gone and
/// latest-intent-wins dedup prevents stale replays.
class SyncSavedJobsUseCase {
  const SyncSavedJobsUseCase({required this.repository});

  final SavedJobsRepository repository;

  Future<SavedJobsSyncReport> call() {
    return repository.syncPendingOps();
  }

  Future<int> pendingCount() async {
    final ops = await repository.getPendingOps();
    return ops.length;
  }
}
