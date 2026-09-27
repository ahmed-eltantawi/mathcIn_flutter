import 'package:MatchIn/features/roadmap/data/models/roadmap_node.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/rewarded_ad_card.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/roadmap_list_widget.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/roadmap_xp_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoadmapContentWidget extends StatelessWidget {
  const RoadmapContentWidget({
    super.key,
    required this.nodes,
    this.collectedTreasures = const {},
    this.rewardedAdXp = 0,
  });

  final List<RoadmapNode> nodes;
  final Set<int> collectedTreasures;
  final int rewardedAdXp;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Independent XP Progress Bar
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 6.h),
          child: RoadmapXpBar(
            nodes: nodes,
            collectedTreasures: collectedTreasures,
            rewardedAdXp: rewardedAdXp,
          ),
        ),

        // Watch Ad & Earn 50 XP Action Card
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          child: const RewardedAdCard(),
        ),

        // Winding Roadmap List with Path & Floating Lotties
        Expanded(
          child: RoadmapListWidget(
            nodes: nodes,
            collectedTreasures: collectedTreasures,
          ),
        ),
      ],
    );
  }
}
