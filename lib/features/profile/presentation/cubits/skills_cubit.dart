import 'package:MatchIn/features/profile/domain/entities/add_candidate_skill_params.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_skill_entity.dart';
import 'package:MatchIn/features/profile/domain/use_cases/add_candidate_skill_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_candidate_skills_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/remove_candidate_skill_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/skills_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SkillsCubit extends Cubit<SkillsState> {
  SkillsCubit({
    required this.getCandidateSkillsUseCase,
    required this.addCandidateSkillUseCase,
    required this.removeCandidateSkillUseCase,
  }) : super(const SkillsInitial());

  final GetCandidateSkillsUseCase getCandidateSkillsUseCase;
  final AddCandidateSkillUseCase addCandidateSkillUseCase;
  final RemoveCandidateSkillUseCase removeCandidateSkillUseCase;

  List<CandidateSkillEntity> _skills = [];

  Future<void> getCandidateSkills() async {
    emit(const SkillsLoading());

    final result = await getCandidateSkillsUseCase();

    result.fold(
      (failure) {
        emit(SkillsFailure(message: failure.message));
      },
      (skills) {
        _skills = skills;

        emit(SkillsSuccess(skills: List.unmodifiable(_skills)));
      },
    );
  }

  Future<void> addSkill({required String name}) async {
    final result = await addCandidateSkillUseCase(
      AddCandidateSkillParams(name: name),
    );

    result.fold(
      (failure) {
        emit(SkillsFailure(message: failure.message));
      },
      (skill) {
        _skills = [skill, ..._skills];

        emit(SkillsSuccess(skills: List.unmodifiable(_skills)));
      },
    );
  }

  Future<void> removeSkill(int candidateSkillId) async {
    final result = await removeCandidateSkillUseCase(candidateSkillId);

    result.fold(
      (failure) {
        emit(SkillsFailure(message: failure.message));
      },
      (_) {
        _skills = _skills
            .where((skill) => skill.id != candidateSkillId)
            .toList();

        emit(SkillsSuccess(skills: List.unmodifiable(_skills)));
      },
    );
  }
}
