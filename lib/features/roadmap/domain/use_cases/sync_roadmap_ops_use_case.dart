import 'package:MatchIn/features/roadmap/domain/entities/roadmap_sync_report.dart';
import 'package:MatchIn/features/roadmap/domain/repositories/roadmap_repository.dart';

/// Replays due durable ops in FIFO order with bounded exponential backoff.
/// Safe to call on every reconnect, foreground return, and manual retry:
/// already-synchronized ops are gone, duplicates collapse by stable op key.
class SyncRoadmapOpsUseCase {
  const SyncRoadmapOpsUseCase({required this.repository});

  final RoadmapRepository repository;

  Future<RoadmapSyncReport> call() {
    return repository.syncPendingOps();
  }

  Future<int> pendingCount() async {
    final ops = await repository.getPendingOps();
    return ops.length;
  }
}
