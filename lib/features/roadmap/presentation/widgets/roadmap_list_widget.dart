import 'package:MatchIn/core/extensions/bottom_sheet_extensions.dart';
import 'package:MatchIn/core/extensions/snack_bar_extensions.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_item_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_node.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/roadmap_cubit/roadmap_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/skill_task_cubit/skill_task_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/treasure_cubit/treasure_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/utils/roadmap_layout_utils.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/roadmap_item_widget.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/roadmap_lottie_decoration.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/roadmap_path_painter.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/skill_details_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoadmapListWidget extends StatefulWidget {
  const RoadmapListWidget({
    super.key,
    required this.nodes,
    this.collectedTreasures = const {},
  });

  final List<RoadmapNode> nodes;
  final Set<int> collectedTreasures;

  @override
  State<RoadmapListWidget> createState() => _RoadmapListWidgetState();
}

class _RoadmapListWidgetState extends State<RoadmapListWidget> {
  final GlobalKey _stackKey = GlobalKey();
  List<GlobalKey> _circleKeys = [];
  List<Offset> _nodeCenters = [];

  void _syncKeys(int count) {
    if (_circleKeys.length != count) {
      _circleKeys = List.generate(count, (_) => GlobalKey());
    }
  }

  void _updateNodeCenters() {
    if (!mounted) return;
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null || _circleKeys.isEmpty) return;

    final List<Offset> newCenters = [];
    for (final key in _circleKeys) {
      final circleBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (circleBox != null) {
        final localCenter = stackBox.globalToLocal(
          circleBox.localToGlobal(
            Offset(circleBox.size.width / 2, circleBox.size.height / 2),
          ),
        );
        newCenters.add(localCenter);
      }
    }

    if (newCenters.length == _circleKeys.length) {
      bool changed = _nodeCenters.length != newCenters.length;
      if (!changed) {
        for (int i = 0; i < newCenters.length; i++) {
          if ((_nodeCenters[i] - newCenters[i]).distance > 0.5) {
            changed = true;
            break;
          }
        }
      }
      if (changed) {
        setState(() {
          _nodeCenters = newCenters;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = RoadmapItem.buildItems(widget.nodes);
    _syncKeys(items.length);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateNodeCenters();
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final maxOffset = (screenWidth * 0.28).clamp(60.0.w, 120.0.w);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 36.h, horizontal: 16.w),
            child: Stack(
              key: _stackKey,
              clipBehavior: Clip.none,
              children: [
                // Layer 1: Winding curve Path CustomPaint
                Positioned.fill(
                  child: CustomPaint(
                    painter: RoadmapPathPainter(nodeCenters: _nodeCenters),
                  ),
                ),

                // Layer 2 & 3: Task Nodes, Milestone Treasures & Lottie Decorations
                Column(
                  children: List.generate(items.length, (itemIndex) {
                    final item = items[itemIndex];
                    final horizontalShift =
                        RoadmapLayoutUtils.calculateOrganicOffset(
                          itemIndex,
                          maxOffset,
                        );

                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Transform.translate(
                            offset: Offset(horizontalShift, 0),
                            child: Center(
                              child: RoadmapItemWidget(
                                item: item,
                                nodes: widget.nodes,
                                collectedTreasures: widget.collectedTreasures,
                                circleKey: _circleKeys[itemIndex],
                                onNodeTap: (node) => _onNodeTap(context, node),
                                onTreasureClaimSuccess: (milestoneIndex) =>
                                    _onTreasureClaimSuccess(
                                      context: context,
                                      milestoneIndex: milestoneIndex,
                                    ),
                                onTreasureLockedTap: (targetIndex) =>
                                    _onTreasureLockedTap(
                                      context: context,
                                      targetNodeIndex: targetIndex,
                                    ),
                              ),
                            ),
                          ),
                          RoadmapLottieDecoration(
                            index: itemIndex,
                            horizontalShift: horizontalShift,
                            maxOffset: maxOffset,
                            screenWidth: screenWidth,
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onNodeTap(BuildContext context, RoadmapNode node) {
    if (node.status == RoadmapTaskStatus.locked) {
      context.showWarningSnackBar(
        'Complete the previous task first to unlock!',
      );
      return;
    }

    final roadmapCubit = context.read<RoadmapCubit>();
    final skillTaskCubit = context.read<SkillTaskCubit>();

    context.showAppBottomSheet(
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: roadmapCubit),
          BlocProvider.value(value: skillTaskCubit),
        ],
        child: SkillDetailsSheet(node: node),
      ),
    );
  }

  void _onTreasureClaimSuccess({
    required BuildContext context,
    required int milestoneIndex,
  }) async {
    // Scope the reward to the selected roadmap; the success SnackBar
    // shows only on the first collection (repeat taps are no-ops).
    final roadmapId = context.read<RoadmapCubit>().selectedRoadmapId;
    if (roadmapId == null) return;
    final isNew = await context.read<TreasureCubit>().claimTreasure(
      roadmapId: roadmapId,
      milestoneIndex: milestoneIndex,
    );
    if (!context.mounted || !isNew) return;
    context.showSuccessSnackBar('🎉 Milestone Claimed! +50 XP Added!');
  }

  void _onTreasureLockedTap({
    required BuildContext context,
    required int targetNodeIndex,
  }) {
    final requiredNodeNumber = targetNodeIndex + 1;
    context.showWarningSnackBar(
      'Complete task #$requiredNodeNumber to unlock this +50 XP milestone!',
    );
  }
}
