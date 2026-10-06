import 'package:MatchIn/features/notification/domain/entities/notification_entity.dart';
import 'package:equatable/equatable.dart';

class PaginatedNotificationsEntity extends Equatable {
  const PaginatedNotificationsEntity({
    required this.notifications,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.hasMorePages,
  });

  final List<NotificationEntity> notifications;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasMorePages;

  PaginatedNotificationsEntity copyWith({
    List<NotificationEntity>? notifications,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? hasMorePages,
  }) {
    return PaginatedNotificationsEntity(
      notifications: notifications ?? this.notifications,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      hasMorePages: hasMorePages ?? this.hasMorePages,
    );
  }

  @override
  List<Object?> get props => [
    notifications,
    currentPage,
    lastPage,
    total,
    hasMorePages,
  ];
}
