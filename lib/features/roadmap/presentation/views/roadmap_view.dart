import 'dart:async';

import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/networking/connectivity_cubit.dart';
import 'package:MatchIn/core/networking/connectivity_state.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_node.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/roadmap_cubit/roadmap_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/skill_task_cubit/skill_task_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/treasure_cubit/treasure_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/xp_cubit/xp_cubit.dart';
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
            BlocProvider(create: (_) => getIt<TreasureCubit>()),
            BlocProvider(create: (_) => getIt<SkillTaskCubit>()),
            BlocProvider(
              create: (_) => getIt<RoadmapXpCubit>()..loadCandidateXp(),
            ),
          ],
          child: _RoadmapSideEffects(child: RoadmapViewBody(nodes: nodes)),
        ),
      ),
    );
  }
}

/// View-layer side effects: per-roadmap ledger/XP loads, plus sync
/// triggers on connectivity restore and foreground return.
///
/// Mobile OSes may delay background work, so sync fires opportunistically
/// here (reconnect + resume) alongside the manual retry path — never
/// presented as continuous background execution.
class _RoadmapSideEffects extends StatefulWidget {
  const _RoadmapSideEffects({required this.child});

  final Widget child;

  @override
  State<_RoadmapSideEffects> createState() => _RoadmapSideEffectsState();
}

class _RoadmapSideEffectsState extends State<_RoadmapSideEffects>
    with WidgetsBindingObserver {
  StreamSubscription<ConnectivityState>? _connectivitySub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _connectivitySub = context.read<ConnectivityCubit>().stream.listen(
      _onConnectivityChanged,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Foreground return: replay anything queued while suspended.
    if (state == AppLifecycleState.resumed && mounted) {
      _replayPendingOps();
    }
  }

  void _onConnectivityChanged(ConnectivityState state) {
    if (!mounted) return;
    if (state.isReconnected || state.isOnline) {
      _replayPendingOps();
    }
  }

  Future<void> _replayPendingOps() async {
    final roadmapCubit = context.read<RoadmapCubit>();
    final synced = await roadmapCubit.syncPending();
    if (!mounted) return;
    if (synced) {
      await context.read<RoadmapXpCubit>().loadCandidateXp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RoadmapCubit, RoadmapState>(
      listener: (context, state) {
        if (state is RoadmapDetailsSuccess) {
          context.read<TreasureCubit>().loadLedger(state.details.id);
          context.read<RoadmapXpCubit>().loadRoadmapXp(state.details.id);
        }
      },
      child: widget.child,
    );
  }
}
