import 'package:MatchIn/features/home/domain/use_cases/get_home_dashboard_use_case.dart';
import 'package:MatchIn/features/home/presentation/cubit/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required this.getHomeDashboardUseCase})
    : super(const HomeInitial());

  final GetHomeDashboardUseCase getHomeDashboardUseCase;

  Future<void> getHomeDashboard() async {
    emit(const HomeLoading());

    final result = await getHomeDashboardUseCase();

    result.fold(
      (failure) => emit(HomeError(failure.message)),
      (dashboard) => emit(HomeLoaded(dashboard)),
    );
  }
}
