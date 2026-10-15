import 'package:MatchIn/features/profile/domain/entities/add_candidate_skill_params.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_skill_entity.dart';
import 'package:MatchIn/features/profile/domain/use_cases/add_candidate_skill_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_candidate_skills_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/remove_candidate_skill_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/search_skills_use_case.dart';

import 'skills_state.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class SkillsCubit extends Cubit<SkillsState> {
  SkillsCubit({
    required this.getCandidateSkillsUseCase,
    required this.addCandidateSkillUseCase,
    required this.removeCandidateSkillUseCase,
    required this.searchSkillsUseCase,
  }) : super(const SkillsInitial());

  final GetCandidateSkillsUseCase getCandidateSkillsUseCase;
  final AddCandidateSkillUseCase addCandidateSkillUseCase;
  final RemoveCandidateSkillUseCase removeCandidateSkillUseCase;
  final SearchSkillsUseCase searchSkillsUseCase;

  List<CandidateSkillEntity> _skills = [];
  bool _addInFlight = false;
  final Set<int> _removingIds = {};
  int _searchSequence = 0;

  /// Sticky session flag: once any Add/Delete succeeds it stays
  /// true until the screen is closed. Failures never reset it.
  bool _hasChanges = false;

  bool get hasChanges => _hasChanges;

  Future<void> getCandidateSkills() async {
    emit(const SkillsLoading());

    final result = await getCandidateSkillsUseCase();
    if (isClosed) return;

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

  /// Returns true when the skill was added. The UI clears its input
  /// only on true, preserving entered text after failures.
  Future<bool> addSkill({required String name}) async {
    if (_addInFlight) return false;
    _addInFlight = true;

    final result = await addCandidateSkillUseCase(
      AddCandidateSkillParams(name: name),
    );
    if (isClosed) return false;
    _addInFlight = false;

    return result.fold(
      (failure) {
        emit(
          SkillsActionFailure(
            skills: List.unmodifiable(_skills),
            message: failure.message,
          ),
        );
        return false;
      },
      (skill) {
        _skills = [skill, ..._skills];
        _hasChanges = true;

        emit(SkillsSuccess(skills: List.unmodifiable(_skills)));
        return true;
      },
    );
  }

  Future<bool> removeSkill(int candidateSkillId) async {
    if (_removingIds.contains(candidateSkillId)) return false;
    _removingIds.add(candidateSkillId);

    final result = await removeCandidateSkillUseCase(candidateSkillId);
    if (isClosed) return false;
    _removingIds.remove(candidateSkillId);

    return result.fold(
      (failure) {
        emit(
          SkillsActionFailure(
            skills: List.unmodifiable(_skills),
            message: failure.message,
          ),
        );
        return false;
      },
      (_) {
        _skills = _skills
            .where((skill) => skill.id != candidateSkillId)
            .toList();
        _hasChanges = true;

        emit(SkillsSuccess(skills: List.unmodifiable(_skills)));
        return true;
      },
    );
  }

  Future<void> searchSkills(String query) async {
    final sequence = ++_searchSequence;

    final result = await searchSkillsUseCase(query);
    if (isClosed || sequence != _searchSequence) return;

    result.fold(
      (failure) {
        emit(
          SkillsActionFailure(
            skills: List.unmodifiable(_skills),
            message: failure.message,
          ),
        );
      },
      (suggestions) {
        emit(
          SkillsSearchSuccess(
            skills: List.unmodifiable(_skills),
            suggestions: suggestions,
          ),
        );
      },
    );
  }

  void clearSearch() {
    emit(SkillsSearchCleared(skills: List.unmodifiable(_skills)));
  }
}
