import 'package:equatable/equatable.dart';
import 'package:MatchIn/features/home/domain/entities/home_dashboard_entity.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeLoaded extends HomeState {
  const HomeLoaded(this.dashboard, {this.isRefreshing = false});

  final HomeDashboardEntity dashboard;
  final bool isRefreshing;

  @override
  List<Object?> get props => [dashboard, isRefreshing];
}

final class HomeError extends HomeState {
  const HomeError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
