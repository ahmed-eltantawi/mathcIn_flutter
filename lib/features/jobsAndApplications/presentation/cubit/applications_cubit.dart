import 'dart:async';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/application_entity.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/get_applications_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/use_case/get_cached_applications_use_case.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/applications_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ApplicationsCubit extends Cubit<ApplicationsState> {
  ApplicationsCubit({
    required this.getApplicationsUseCase,
    required this.getCachedApplicationsUseCase,
  }) : super(const ApplicationsInitial());

  final GetApplicationsUseCase getApplicationsUseCase;
  final GetCachedApplicationsUseCase getCachedApplicationsUseCase;

  String? _statusFilter;
  String? _searchQuery;
  Timer? _debounceTimer;

  String? get currentStatusFilter => _statusFilter;
  String? get currentSearchQuery => _searchQuery;

  Future<void> fetchApplications({
    String? status,
    String? search,
    bool isRefresh = false,
  }) async {
    _statusFilter = status ?? _statusFilter;
    _searchQuery = search ?? _searchQuery;

    if (!isRefresh && (state is ApplicationsInitial || state is ApplicationsLoading)) {
      final cached = await getCachedApplicationsUseCase(
        status: _statusFilter,
        search: _searchQuery,
      );
      cached.fold(
        (_) {},
        (cachedData) {
          if (cachedData != null && cachedData.applications.isNotEmpty) {
            emit(
              ApplicationsLoaded(
                applications: cachedData.applications,
                currentPage: cachedData.currentPage,
                lastPage: cachedData.lastPage,
                total: cachedData.total,
                hasNextPage: cachedData.hasNextPage,
                statusFilter: _statusFilter,
                searchQuery: _searchQuery,
                isFromCache: true,
              ),
            );
          }
        },
      );
    }

    final currentState = state;
    if (isRefresh && currentState is ApplicationsLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    } else if (state is! ApplicationsLoaded) {
      emit(const ApplicationsLoading());
    }

    final result = await getApplicationsUseCase(
      status: _statusFilter,
      search: _searchQuery,
      page: 1,
    );

    result.fold(
      (failure) {
        final stateOnFail = state;
        if (stateOnFail is ApplicationsLoaded) {
          emit(
            stateOnFail.copyWith(
              isRefreshing: false,
              isLoadingMore: false,
              errorMessage: failure.message,
            ),
          );
        } else {
          emit(ApplicationsError(failure.message));
        }
      },
      (paginated) {
        if (paginated.applications.isEmpty) {
          emit(
            ApplicationsEmpty(
              statusFilter: _statusFilter,
              searchQuery: _searchQuery,
            ),
          );
        } else {
          emit(
            ApplicationsLoaded(
              applications: paginated.applications,
              currentPage: paginated.currentPage,
              lastPage: paginated.lastPage,
              total: paginated.total,
              hasNextPage: paginated.hasNextPage,
              statusFilter: _statusFilter,
              searchQuery: _searchQuery,
              isFromCache: false,
            ),
          );
        }
      },
    );
  }

  Future<void> loadMoreApplications() async {
    final currentState = state;
    if (currentState is! ApplicationsLoaded) return;
    if (currentState.isLoadingMore || currentState.isRefreshing || !currentState.hasNextPage) return;

    final nextPage = currentState.currentPage + 1;
    emit(currentState.copyWith(isLoadingMore: true));

    final result = await getApplicationsUseCase(
      status: _statusFilter,
      search: _searchQuery,
      page: nextPage,
    );

    result.fold(
      (failure) {
        emit(
          currentState.copyWith(
            isLoadingMore: false,
            errorMessage: failure.message,
          ),
        );
      },
      (paginated) {
        final updatedList = List<ApplicationEntity>.from(currentState.applications)
          ..addAll(paginated.applications);
        emit(
          ApplicationsLoaded(
            applications: updatedList,
            currentPage: paginated.currentPage,
            lastPage: paginated.lastPage,
            total: paginated.total,
            hasNextPage: paginated.hasNextPage,
            statusFilter: _statusFilter,
            searchQuery: _searchQuery,
            isFromCache: false,
            isLoadingMore: false,
          ),
        );
      },
    );
  }

  void searchApplications(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      final trimmed = query.trim();
      fetchApplications(search: trimmed.isEmpty ? null : trimmed);
    });
  }

  void setStatusFilter(String? status) {
    fetchApplications(status: status);
  }

  void updateLocalApplication(ApplicationEntity updatedApp) {
    final currentState = state;
    if (currentState is ApplicationsLoaded) {
      final updatedList = currentState.applications.map((app) {
        return app.id == updatedApp.id ? updatedApp : app;
      }).toList();
      emit(currentState.copyWith(applications: updatedList));
    }
  }

  void prependApplication(ApplicationEntity newApp) {
    final currentState = state;
    if (currentState is ApplicationsLoaded) {
      final updatedList = List<ApplicationEntity>.from(currentState.applications);
      updatedList.removeWhere((app) => app.id == newApp.id);
      updatedList.insert(0, newApp);
      emit(currentState.copyWith(applications: updatedList));
    } else {
      emit(
        ApplicationsLoaded(
          applications: [newApp],
          currentPage: 1,
          lastPage: 1,
          total: 1,
          hasNextPage: false,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
