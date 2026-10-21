/// Durable pending-sync operation for offline-first roadmap mutations.
///
/// Persisted as JSON in [SharedPreferencesHelper] so the queue survives
/// app restarts, process death, and device reboots. [opKey] is stable per
/// logical action (e.g. `complete_7`, `treasure_1_2`) and is used to
/// deduplicate retries: enqueueing an op with an existing key replaces the
/// older entry instead of duplicating it.
class RoadmapSyncOp {
  const RoadmapSyncOp({
    required this.opKey,
    required this.type,
    required this.payload,
    required this.createdAtMs,
    this.attempts = 0,
    this.nextRetryAtMs,
  });

  factory RoadmapSyncOp.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'];
    return RoadmapSyncOp(
      opKey: json['opKey']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      payload: payload is Map<String, dynamic>
          ? payload
          : const <String, dynamic>{},
      createdAtMs: (json['createdAtMs'] as num?)?.toInt() ?? 0,
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
      nextRetryAtMs: (json['nextRetryAtMs'] as num?)?.toInt(),
    );
  }

  final String opKey;
  final String type;
  final Map<String, dynamic> payload;
  final int createdAtMs;
  final int attempts;
  final int? nextRetryAtMs;

  static const String typeCompleteTask = 'complete_task';
  static const String typeAwardXp = 'award_xp';

  /// Bounded exponential backoff: 2s, 8s, 32s, ... capped at 5 minutes.
  static int backoffDelayMs(int attempts) {
    var delay = 2000;
    for (var i = 0; i < attempts; i++) {
      delay *= 4;
      if (delay >= 300000) return 300000;
    }
    return delay;
  }

  static String completeTaskKey(int taskId) => 'complete_$taskId';

  static String treasureKey(int roadmapId, int milestoneIndex) =>
      'treasure_${roadmapId}_$milestoneIndex';

  RoadmapSyncOp withAttempt(int nowMs) {
    final nextAttempts = attempts + 1;
    return RoadmapSyncOp(
      opKey: opKey,
      type: type,
      payload: payload,
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
      'payload': payload,
      'createdAtMs': createdAtMs,
      'attempts': attempts,
    };
    final retryAt = nextRetryAtMs;
    if (retryAt != null) map['nextRetryAtMs'] = retryAt;
    return map;
  }
}
