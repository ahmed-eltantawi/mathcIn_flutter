part of 'treasure_cubit.dart';

@immutable
sealed class TreasureState {
  const TreasureState();
}

final class TreasureInitial extends TreasureState {
  const TreasureInitial();
}

final class TreasureLoaded extends TreasureState {
  const TreasureLoaded({
    required this.roadmapId,
    this.collectedTreasures = const {},
    this.syncedTreasures = const {},
  });

  /// Roadmap this ledger belongs to (stable server id scoping).
  final int roadmapId;

  /// Milestone indices collected locally (durable, survives restarts).
  final Set<int> collectedTreasures;

  /// Milestone indices whose +50 XP the server already confirmed.
  final Set<int> syncedTreasures;

  /// Collected but awaiting server confirmation (offline claims).
  Set<int> get pendingXpTreasures =>
      collectedTreasures.difference(syncedTreasures);
}

final class TreasureFailure extends TreasureState {
  const TreasureFailure({required this.errorMessage});

  final String errorMessage;
}
