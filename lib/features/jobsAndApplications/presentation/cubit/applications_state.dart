import 'package:MatchIn/features/jobsAndApplications/domain/entities/application_entity.dart';
import 'package:equatable/equatable.dart';

abstract class ApplicationsState extends Equatable {
  const ApplicationsState();

  @override
  List<Object?> get props => [];
}

class ApplicationsInitial extends ApplicationsState {
  const ApplicationsInitial();
}

class ApplicationsLoading extends ApplicationsState {
  const ApplicationsLoading();
}

class ApplicationsLoaded extends ApplicationsState {
  const ApplicationsLoaded({
    required this.applications,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.hasNextPage,
    this.statusFilter,
    this.searchQuery,
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.isFromCache = false,
    this.errorMessage,
  });

  final List<ApplicationEntity> applications;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasNextPage;
  final String? statusFilter;
  final String? searchQuery;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool isFromCache;
  final String? errorMessage;

  ApplicationsLoaded copyWith({
    List<ApplicationEntity>? applications,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? hasNextPage,
    String? statusFilter,
    String? searchQuery,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? isFromCache,
    String? errorMessage,
  }) {
    return ApplicationsLoaded(
      applications: applications ?? this.applications,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      statusFilter: statusFilter ?? this.statusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isFromCache: isFromCache ?? this.isFromCache,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        applications,
        currentPage,
        lastPage,
        total,
        hasNextPage,
        statusFilter,
        searchQuery,
        isRefreshing,
        isLoadingMore,
        isFromCache,
        errorMessage,
      ];
}

class ApplicationsEmpty extends ApplicationsState {
  const ApplicationsEmpty({this.statusFilter, this.searchQuery});

  final String? statusFilter;
  final String? searchQuery;

  @override
  List<Object?> get props => [statusFilter, searchQuery];
}

class ApplicationsError extends ApplicationsState {
  const ApplicationsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
