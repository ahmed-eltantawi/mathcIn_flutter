import 'package:flutter/material.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_item_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_node.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/roadmap_node.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/treasure_box_node.dart';

/// Reusable widget for rendering individual roadmap items (Task Node vs Milestone Treasure).
class RoadmapItemWidget extends StatelessWidget {
  const RoadmapItemWidget({
    super.key,
    required this.item,
    required this.nodes,
    required this.collectedTreasures,
    required this.circleKey,
    required this.onNodeTap,
    required this.onTreasureClaimSuccess,
    required this.onTreasureLockedTap,
  });

  final RoadmapItem item;
  final List<RoadmapNode> nodes;
  final Set<int> collectedTreasures;
  final Key circleKey;

  final ValueChanged<RoadmapNode> onNodeTap;
  final ValueChanged<int> onTreasureClaimSuccess;
  final ValueChanged<int> onTreasureLockedTap;

  @override
  Widget build(BuildContext context) {
    if (item.isTreasure) {
      final milestoneIndex = item.milestoneIndex!;
      final targetIndex = item.targetNodeIndex!;
      // Eligibility derives from actual completion state of the leading
      // task nodes (all first milestoneIndex*5 completed), not from a
      // single position check.
      final isUnlocked = RoadmapItem.isMilestoneUnlocked(nodes, milestoneIndex);
      final isClaimed = collectedTreasures.contains(milestoneIndex);

      return TreasureBoxNodeWidget(
        milestoneIndex: milestoneIndex,
        isUnlocked: isUnlocked,
        isClaimed: isClaimed,
        circleKey: circleKey,
        onClaimSuccess: () => onTreasureClaimSuccess(milestoneIndex),
        onLockedTap: () => onTreasureLockedTap(targetIndex),
      );
    }

    final node = item.node!;
    return RoadmapTaskNode(
      node: node,
      circleKey: circleKey,
      onTap: () => onNodeTap(node),
    );
  }
}
