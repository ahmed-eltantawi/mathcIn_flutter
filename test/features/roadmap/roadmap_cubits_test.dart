import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/roadmap_cubit/roadmap_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/skill_task_cubit/skill_task_cubit.dart';
import 'package:MatchIn/features/roadmap/presentation/manager/treasure_cubit/treasure_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferencesService sharedPreferencesService;
  late RoadmapCubit roadmapCubit;
  late TreasureCubit treasureCubit;
  late SkillTaskCubit skillTaskCubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final helper = SharedPreferencesHelper(preferences: prefs);
    sharedPreferencesService = SharedPreferencesService(helper);

    roadmapCubit = RoadmapCubit(
      sharedPreferencesService: sharedPreferencesService,
    );
    treasureCubit = TreasureCubit(
      sharedPreferencesService: sharedPreferencesService,
    );
    skillTaskCubit = SkillTaskCubit(
      sharedPreferencesService: sharedPreferencesService,
    );
  });

  group('Roadmap Features Cubit Unit Tests', () {
    test('RoadmapCubit emits RoadmapSuccess with normalized nodes', () {
      roadmapCubit.fetchRoadmapNodes();
      expect(roadmapCubit.state, isA<RoadmapSuccess>());
      final state = roadmapCubit.state as RoadmapSuccess;
      expect(state.nodes.isNotEmpty, isTrue);
    });

    test('TreasureCubit loads and claims treasure milestone', () async {
      treasureCubit.loadCollectedTreasures();
      expect(treasureCubit.state, isA<TreasureLoaded>());

      await treasureCubit.claimTreasureReward(1);
      final state = treasureCubit.state as TreasureLoaded;
      expect(state.collectedTreasures.contains(1), isTrue);
    });

    test('SkillTaskCubit toggles task completion and persists state', () async {
      skillTaskCubit.loadCompletedTasks();
      expect(skillTaskCubit.state, isA<SkillTaskLoaded>());

      await skillTaskCubit.toggleTaskCompletion(taskId: 'task-1');
      final state = skillTaskCubit.state as SkillTaskLoaded;
      expect(state.completedTaskIds.contains('task-1'), isTrue);
    });
    test('RoadmapCubit adds rewarded ad XP (+50 XP) and persists state', () async {
      roadmapCubit.fetchRoadmapNodes();
      expect(roadmapCubit.state, isA<RoadmapSuccess>());

      await roadmapCubit.addRewardedAdXp(50);
      final state = roadmapCubit.state as RoadmapSuccess;
      expect(state.rewardedAdXp, equals(50));
      expect(sharedPreferencesService.getRewardedAdXp(), equals(50));
    });
  });
}
