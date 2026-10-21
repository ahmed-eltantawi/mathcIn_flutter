/// Centralized treasure-box reward rules (single source of truth).
///
/// One treasure box unlocks per five completed roadmap task nodes:
/// nodes 1-5 unlock box 1, nodes 6-10 unlock box 2, and so on.
/// Each collected box awards [+50 XP] through the canonical
/// `PATCH /roadmaps/xp` route exactly once per milestone.
abstract class TreasureRewards {
  /// Task nodes required per treasure milestone.
  static const int nodesPerMilestone = 5;

  /// XP awarded per collected treasure box.
  static const int xpPerMilestone = 50;

  static String reasonFor(int milestoneIndex) =>
      'Treasure milestone $milestoneIndex collected (+$xpPerMilestone XP)';

  /// Milestone indices (1-based) unlocked by [completedCount] completions
  /// among the leading task nodes.
  static List<int> unlockedMilestones(int completedCount) {
    final count = completedCount ~/ nodesPerMilestone;
    return List<int>.generate(count, (i) => i + 1);
  }
}
