/// Durable pending-sync operation for offline-first saved-jobs mutations.
///
/// Persisted as JSON in [SharedPreferencesHelper] so the queue survives
/// app restarts, process death, and device reboots. [opKey] is stable per
/// job (`savejob_<id>`): enqueueing a newer intent for the same job
/// replaces the older entry, so rapid save/unsave sequences preserve the
/// latest user intent instead of replaying stale ones.
class SavedJobSyncOp {
  const SavedJobSyncOp({
    required this.opKey,
    required this.type,
    required this.jobPostId,
    required this.createdAtMs,
    this.attempts = 0,
    this.nextRetryAtMs,
  });

  factory SavedJobSyncOp.fromJson(Map<String, dynamic> json) {
    return SavedJobSyncOp(
      opKey: json['opKey']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      jobPostId: (json['jobPostId'] as num?)?.toInt() ?? 0,
      createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      nextRetryAtMs: (json['nextRetryAtMs'] as num?)?.toInt(),
    );
  }

  final String opKey;
  final String type;
  final int jobPostId;
  final int createdAtMs;
  final int attempts;
  final int? nextRetryAtMs;

  static const String typeSave = 'save';
  static const String typeUnsave = 'unsave';

  static String keyFor(int jobPostId) => 'savejob_$jobPostId';

  /// Bounded exponential backoff: 2s, 8s, 32s, ... capped at 5 minutes.
  static int backoffDelayMs(int attempts) {
    var delay = 2000;
    for (var i = 0; i < attempts; i++) {
      delay *= 4;
      if (delay >= 300000) return 300000;
    }
    return delay;
  }

  SavedJobSyncOp withAttempt(int nowMs) {
    final nextAttempts = attempts + 1;
    return SavedJobSyncOp(
      opKey: opKey,
      type: type,
      jobPostId: jobPostId,
      createdAtMs: createdAtMs,
      attempts: nextAttempts,
      nextRetryAtMs: nowMs + backoffDelayMs(nextAttempts),
    );
  }

  bool isDue(int nowMs) => nextRetryAtMs == null || nextRetryAtMs! <= nowMs;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'opKey': opKey,
      'type': type,
      'jobPostId': jobPostId,
      'createdAtMs': createdAtMs,
      'attempts': attempts,
    };
    final retryAt = nextRetryAtMs;
    if (retryAt != null) map['nextRetryAtMs'] = retryAt;
    return map;
  }
}
