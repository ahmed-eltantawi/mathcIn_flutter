import 'package:equatable/equatable.dart';
import 'package:MatchIn/features/notification/domain/entities/notification_entity.dart';

enum NotificationsStatus {
  initial,
  loading,
  paginationLoading,
  success,
  failure,
}

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.unreadCount = 0,
    this.unreadOnly = false,
    this.currentPage = 1,
    this.hasMorePages = false,
    this.errorMessage,
  });

  final NotificationsStatus status;
  final List<NotificationEntity> notifications;
  final int unreadCount;
  final bool unreadOnly;
  final int currentPage;
  final bool hasMorePages;
  final String? errorMessage;

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<NotificationEntity>? notifications,
    int? unreadCount,
    bool? unreadOnly,
    int? currentPage,
    bool? hasMorePages,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      unreadOnly: unreadOnly ?? this.unreadOnly,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    notifications,
    unreadCount,
    unreadOnly,
    currentPage,
    hasMorePages,
    errorMessage,
  ];
}
