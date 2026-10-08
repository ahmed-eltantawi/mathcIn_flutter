import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:MatchIn/features/notification/domain/entities/notification_entity.dart';
import 'package:MatchIn/features/notification/domain/services/notification_service.dart';
import 'package:MatchIn/features/notification/domain/usecases/get_notifications_use_case.dart';
import 'package:MatchIn/features/notification/domain/usecases/get_unread_notifications_count_use_case.dart';
import 'package:MatchIn/features/notification/domain/usecases/mark_all_notifications_as_read_use_case.dart';
import 'package:MatchIn/features/notification/domain/usecases/mark_notification_as_read_use_case.dart';
import 'package:MatchIn/features/notification/presentation/cubit/notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit({
    required this.getNotificationsUseCase,
    required this.getUnreadNotificationsCountUseCase,
    required this.markNotificationAsReadUseCase,
    required this.markAllNotificationsAsReadUseCase,
    required this.notificationService,
  }) : super(const NotificationsState()) {
    _unreadCountSubscription =
        notificationService.unreadCountStream.listen((count) {
      if (!isClosed) {
        emit(state.copyWith(unreadCount: count));
      }
    });
  }

  final GetNotificationsUseCase getNotificationsUseCase;
  final GetUnreadNotificationsCountUseCase getUnreadNotificationsCountUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;
  final MarkAllNotificationsAsReadUseCase markAllNotificationsAsReadUseCase;
  final NotificationService notificationService;

  StreamSubscription<int>? _unreadCountSubscription;

  Future<void> loadNotifications({bool? unreadOnly}) async {
    final filter = unreadOnly ?? state.unreadOnly;
    emit(state.copyWith(
      status: NotificationsStatus.loading,
      unreadOnly: filter,
    ));

    final result = await getNotificationsUseCase(
      page: 1,
      unreadOnly: filter,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: NotificationsStatus.failure,
        errorMessage: failure.message,
      )),
      (paginated) => emit(state.copyWith(
        status: NotificationsStatus.success,
        notifications: paginated.notifications,
        currentPage: paginated.currentPage,
        hasMorePages: paginated.hasMorePages,
        errorMessage: null,
      )),
    );
  }

  Future<void> loadMoreNotifications() async {
    if (!state.hasMorePages ||
        state.status == NotificationsStatus.paginationLoading) {
      return;
    }

    emit(state.copyWith(status: NotificationsStatus.paginationLoading));

    final nextPage = state.currentPage + 1;
    final result = await getNotificationsUseCase(
      page: nextPage,
      unreadOnly: state.unreadOnly,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: NotificationsStatus.success,
        errorMessage: failure.message,
      )),
      (paginated) {
        final existingIds = state.notifications.map((n) => n.id).toSet();
        final newItems = paginated.notifications
            .where((n) => !existingIds.contains(n.id))
            .toList();

        final merged = List<NotificationEntity>.from(state.notifications)
          ..addAll(newItems);

        emit(state.copyWith(
          status: NotificationsStatus.success,
          notifications: merged,
          currentPage: paginated.currentPage,
          hasMorePages: paginated.hasMorePages,
        ));
      },
    );
  }

  Future<void> refreshNotifications() async {
    final result = await getNotificationsUseCase(
      page: 1,
      unreadOnly: state.unreadOnly,
    );

    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.message)),
      (paginated) => emit(state.copyWith(
        status: NotificationsStatus.success,
        notifications: paginated.notifications,
        currentPage: paginated.currentPage,
        hasMorePages: paginated.hasMorePages,
        errorMessage: null,
      )),
    );

    await loadUnreadCount();
  }

  Future<void> setFilter({required bool unreadOnly}) async {
    if (state.unreadOnly == unreadOnly &&
        state.status == NotificationsStatus.success) {
      return;
    }
    await loadNotifications(unreadOnly: unreadOnly);
  }

  Future<void> loadUnreadCount() async {
    final result = await getUnreadNotificationsCountUseCase();
    result.fold(
      (_) => null,
      (count) => emit(state.copyWith(unreadCount: count)),
    );
  }

  Future<void> markAsRead(int notificationId) async {
    final result = await markNotificationAsReadUseCase(id: notificationId);

    result.fold(
      (_) => null,
      (updatedEntity) {
        final updatedList = state.notifications.map((n) {
          if (n.id == notificationId) {
            return updatedEntity;
          }
          return n;
        }).toList();

        final newUnreadCount = state.unreadCount > 0
            ? state.unreadCount - 1
            : 0;

        emit(state.copyWith(
          notifications: state.unreadOnly
              ? updatedList.where((n) => !n.isRead).toList()
              : updatedList,
          unreadCount: newUnreadCount,
        ));
      },
    );
  }

  Future<void> markAllAsRead() async {
    final result = await markAllNotificationsAsReadUseCase();

    result.fold(
      (_) => null,
      (_) {
        final updatedList = state.notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();

        emit(state.copyWith(
          notifications: state.unreadOnly ? [] : updatedList,
          unreadCount: 0,
        ));
      },
    );
  }

  @override
  Future<void> close() {
    _unreadCountSubscription?.cancel();
    return super.close();
  }
}
