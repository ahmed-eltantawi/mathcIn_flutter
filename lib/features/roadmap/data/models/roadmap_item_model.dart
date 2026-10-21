import 'package:MatchIn/features/roadmap/data/models/roadmap_node.dart';
import 'package:MatchIn/features/roadmap/domain/entities/treasure_rewards.dart';

/// Data representation of an item along the winding roadmap path (Node vs Treasure).
class RoadmapItem {
  RoadmapItem.node(this.node, this.taskIndex)
    : milestoneIndex = null,
      targetNodeIndex = null;

  RoadmapItem.treasure(this.milestoneIndex, this.targetNodeIndex)
    : node = null,
      taskIndex = null;

  final RoadmapNode? node;
  final int? taskIndex;
  final int? milestoneIndex;
  final int? targetNodeIndex;

  bool get isTreasure => milestoneIndex != null;

  /// Builds the complete list of items including milestone treasures every 5 tasks
  static List<RoadmapItem> buildItems(List<RoadmapNode> nodes) {
    final List<RoadmapItem> items = [];
    for (int i = 0; i < nodes.length; i++) {
      items.add(RoadmapItem.node(nodes[i], i));
      if ((i + 1) % TreasureRewards.nodesPerMilestone == 0) {
        final milestoneIndex = (i + 1) ~/ TreasureRewards.nodesPerMilestone;
        items.add(RoadmapItem.treasure(milestoneIndex, i));
      }
    }
    return items;
  }

  /// A treasure milestone (1-based) unlocks only when every one of the
  /// first `milestoneIndex * 5` task nodes is completed — never from a
  /// single 5th-position check, and never from hard-coded node counts.
  static bool isMilestoneUnlocked(List<RoadmapNode> nodes, int milestoneIndex) {
    final required = milestoneIndex * TreasureRewards.nodesPerMilestone;
    if (milestoneIndex < 1 || nodes.length < required) return false;
    for (var i = 0; i < required; i++) {
      if (nodes[i].status != RoadmapTaskStatus.completed) return false;
    }
    return true;
  }
}
