import 'package:equatable/equatable.dart';

/// Outcome of one [syncPendingOps] pass over the durable queue.
///
/// Failed ops stay queued with updated retry metadata (bounded
/// exponential backoff) and are never silently discarded.
/// [stoppedForAuth] is true when the pass halted on an expired session so
/// the UI can route through the existing sign-in flow instead of burning
/// retries.
class RoadmapSyncReport extends Equatable {
  const RoadmapSyncReport({
    this.succeeded = 0,
    this.failed = 0,
    this.remaining = 0,
    this.stoppedForAuth = false,
  });

  final int succeeded;
  final int failed;
  final int remaining;
  final bool stoppedForAuth;

  bool get didWork => succeeded > 0;

  @override
  List<Object?> get props => [succeeded, failed, remaining, stoppedForAuth];
}
