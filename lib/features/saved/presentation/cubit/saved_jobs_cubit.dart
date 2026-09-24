import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:MatchIn/features/saved/domain/entities/saved_job_entity.dart';
import 'package:MatchIn/features/saved/domain/use_cases/get_saved_jobs_use_case.dart';
import 'package:MatchIn/features/saved/domain/use_cases/save_job_use_case.dart';
import 'package:MatchIn/features/saved/domain/use_cases/unsave_job_use_case.dart';
import 'package:MatchIn/features/saved/presentation/cubit/saved_jobs_state.dart';

class SavedJobsCubit extends Cubit<SavedJobsState> {
  SavedJobsCubit({
    required this.getSavedJobsUseCase,
    required this.saveJobUseCase,
    required this.unsaveJobUseCase,
  }) : super(const SavedJobsInitial());

  final GetSavedJobsUseCase getSavedJobsUseCase;
  final SaveJobUseCase saveJobUseCase;
  final UnsaveJobUseCase unsaveJobUseCase;

  Future<void> fetchSavedJobs({bool isRefresh = false}) async {
    if (!isRefresh) {
      emit(const SavedJobsLoading());
    }

    // Use dummy data since API is currently broken
    await Future.delayed(const Duration(milliseconds: 800));

    final dummyJobs = [
      const SavedJobEntity(
        id: 1,
        title: 'Junior Flutter Developer',
        company: 'TechNova',
        location: 'Cairo',
        workMode: 'Hybrid',
        experience: '0–2 years',
        jobType: 'Full-time',
        postedDate: '2026-09-21',
        skills: ['Flutter', 'REST API', 'Bloc'],
        matchPercentage: 92,
        isSaved: true,
      ),
      const SavedJobEntity(
        id: 2,
        title: 'Mobile Developer Intern',
        company: 'CodeHub',
        location: 'Remote',
        workMode: 'Remote',
        experience: 'Entry Level',
        jobType: 'Internship',
        postedDate: '2026-09-23',
        skills: ['Flutter', 'Firebase', 'Git'],
        matchPercentage: 86,
        isSaved: true,
      ),
      const SavedJobEntity(
        id: 3,
        title: 'Junior Software Engineer',
        company: 'NextStack',
        location: 'Giza',
        workMode: 'Full-time',
        experience: 'Entry Level',
        jobType: 'On-site',
        postedDate: '2026-09-20',
        skills: ['Dart', 'OOP', 'SQL'],
        matchPercentage: 78,
        isSaved: true,
      ),
    ];

    emit(
      SavedJobsLoaded(
        jobs: dummyJobs,
        currentPage: 1,
        hasMore: false,
      ),
    );
  }

  Future<void> loadMoreSavedJobs() async {
    // Dummy data doesn't have more pages
    return;
  }

  Future<void> toggleBookmark(SavedJobEntity job) async {
    final currentState = state;
    if (currentState is! SavedJobsLoaded) return;

    final targetSaved = !job.isSaved;

    // Optimistic UI update only (no API call)
    final updatedJobs = currentState.jobs
        .map((j) => j.id == job.id ? j.copyWith(isSaved: targetSaved) : j)
        .toList();

    emit(currentState.copyWith(jobs: updatedJobs));
  }
}
