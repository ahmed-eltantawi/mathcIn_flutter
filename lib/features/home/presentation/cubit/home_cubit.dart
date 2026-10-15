import 'package:MatchIn/features/home/domain/entities/home_dashboard_entity.dart';
import 'package:MatchIn/features/home/domain/use_cases/get_cached_home_dashboard_use_case.dart';
import 'package:MatchIn/features/home/domain/use_cases/get_home_dashboard_use_case.dart';
import 'package:MatchIn/features/home/presentation/cubit/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required this.getHomeDashboardUseCase,
    required this.getCachedHomeDashboardUseCase,
  }) : super(const HomeInitial());

  final GetHomeDashboardUseCase getHomeDashboardUseCase;
  final GetCachedHomeDashboardUseCase getCachedHomeDashboardUseCase;

  bool _isFetching = false;

  Future<void> getHomeDashboard() async {
    // --- Prevent overlapping dashboard requests (initial load vs. pull-to-refresh) ---
    if (_isFetching) return;
    _isFetching = true;
    try {
      await _loadDashboard();
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _loadDashboard() async {
    HomeDashboardEntity? cachedDashboard;

    // 1. Instantly load from local cache if available
    final cachedResult = await getCachedHomeDashboardUseCase();
    cachedResult.fold(
      (_) => null,
      (dashboard) {
        if (dashboard != null && dashboard.userName.isNotEmpty) {
          cachedDashboard = dashboard;
          emit(HomeLoaded(dashboard, isRefreshing: true));
        }
      },
    );

    // If no cached data exists, show skeleton placeholder
    if (cachedDashboard == null) {
      emit(const HomeLoading());
    }

    // 2. Fetch fresh dashboard in the background
    final result = await getHomeDashboardUseCase();

    result.fold(
      (failure) {
        // If cached data was already displayed, preserve it rather than replacing with an error screen
        if (cachedDashboard != null) {
          emit(HomeLoaded(cachedDashboard!, isRefreshing: false));
        } else {
          emit(HomeError(failure.message));
        }
      },
      (dashboard) => emit(HomeLoaded(dashboard, isRefreshing: false)),
    );
  }
}
