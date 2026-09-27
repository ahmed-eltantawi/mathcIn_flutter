import 'package:MatchIn/core/widgets/error/app_error.dart';
import 'package:MatchIn/core/widgets/loading/app_loading.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_node.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/roadmap_cubit/roadmap_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/treasure_cubit/treasure_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/roadmap_content_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RoadmapViewBody extends StatelessWidget {
  const RoadmapViewBody({super.key, this.nodes});

  final List<RoadmapNode>? nodes;

  @override
  Widget build(BuildContext context) {
    if (nodes != null && nodes!.isNotEmpty) {
      return RoadmapContentWidget(nodes: nodes!);
    }

    return BlocBuilder<RoadmapCubit, RoadmapState>(
      builder: (context, state) {
        if (state is RoadmapLoading) {
          return const AppLoadingWidget();
        } else if (state is RoadmapSuccess) {
          return BlocBuilder<TreasureCubit, TreasureState>(
            builder: (context, treasureState) {
              final collectedTreasures = treasureState is TreasureLoaded
                  ? treasureState.collectedTreasures
                  : <int>{};

              return RoadmapContentWidget(
                nodes: state.nodes,
                collectedTreasures: collectedTreasures,
                rewardedAdXp: state.rewardedAdXp,
              );
            },
          );
        } else if (state is RoadmapFailure) {
          return AppErrorWidget(
            message: state.errorMessage,
            onRetry: () => context.read<RoadmapCubit>().fetchRoadmapNodes(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
