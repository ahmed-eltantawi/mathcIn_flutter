import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_node.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/roadmap_cubit/roadmap_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/skill_task_cubit/skill_task_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/treasure_cubit/treasure_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/widgets/roadmap_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RoadmapView extends StatelessWidget {
  const RoadmapView({super.key, this.nodes});

  final List<RoadmapNode>? nodes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.myCareerRoadmap,
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<RoadmapCubit>()..loadRoadmaps()),
            BlocProvider(
              create: (_) => getIt<TreasureCubit>()..loadCollectedTreasures(),
            ),
            BlocProvider(create: (_) => getIt<SkillTaskCubit>()),
          ],
          child: RoadmapViewBody(nodes: nodes),
        ),
      ),
    );
  }
}
