import 'package:MatchIn/features/home/presentation/widgets/notification_view_widgets/notification_card.dart';
import 'package:MatchIn/features/home/presentation/widgets/notification_view_widgets/notification_filter_chip.dart';
import 'package:MatchIn/features/home/presentation/widgets/notification_view_widgets/notifications_header.dart';
import 'package:MatchIn/features/notification/presentation/cubit/notifications_cubit.dart';
import 'package:MatchIn/features/notification/presentation/cubit/notifications_state.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationsViewBody extends StatefulWidget {
  const NotificationsViewBody({super.key});

  @override
  State<NotificationsViewBody> createState() => _NotificationsViewBodyState();
}

class _NotificationsViewBodyState extends State<NotificationsViewBody> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    final isNearBottom =
        position.pixels >= position.maxScrollExtent - 200.h;
    if (isNearBottom) {
      context.read<NotificationsCubit>().loadMoreNotifications();
    }
  }

  Future<void> _onRefresh() async {
    await context.read<NotificationsCubit>().refreshNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return BlocConsumer<NotificationsCubit, NotificationsState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        if (state.errorMessage != null &&
            state.status != NotificationsStatus.loading) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            //! ===== Header =====
            NotificationsHeader(
              onMarkAllRead: state.notifications.any((n) => !n.isRead)
                  ? () => context.read<NotificationsCubit>().markAllAsRead()
                  : null,
            ),

            const Divider(height: 1),

            //! ===== Offline Banner =====
            if (state.status == NotificationsStatus.success &&
                state.notifications.isNotEmpty)
              _OfflineBanner(s: s, theme: theme),

            //! ===== Filter Chips =====
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    NotificationFilterChip(
                      label: s.filterAll,
                      isSelected: !state.unreadOnly,
                      onTap: () => context
                          .read<NotificationsCubit>()
                          .setFilter(unreadOnly: false),
                    ),
                    SizedBox(width: 8.w),
                    NotificationFilterChip(
                      label: s.filterUnread,
                      isSelected: state.unreadOnly,
                      onTap: () => context
                          .read<NotificationsCubit>()
                          .setFilter(unreadOnly: true),
                    ),
                  ],
                ),
              ),
            ),

            //! ===== Body Content =====
            Expanded(
              child: _buildBody(context, state, s, theme),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    NotificationsState state,
    S s,
    ThemeData theme,
  ) {
    // Initial loading
    if (state.status == NotificationsStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error with no cached data
    if (state.status == NotificationsStatus.failure &&
        state.notifications.isEmpty) {
      return _ErrorState(
        message: state.errorMessage ?? s.somethingWentWrong,
        s: s,
        onRetry: () => context.read<NotificationsCubit>().loadNotifications(),
      );
    }

    // Empty state
    if (state.status == NotificationsStatus.success &&
        state.notifications.isEmpty) {
      return _EmptyState(
        isUnreadFilter: state.unreadOnly,
        s: s,
        theme: theme,
      );
    }

    // List
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.separated(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 8.h,
        ),
        itemCount:
            state.notifications.length + (state.hasMorePages ? 1 : 0),
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (context, index) {
          if (index == state.notifications.length) {
            return _PaginationLoader(state: state);
          }

          final notification = state.notifications[index];
          return NotificationCard(
            notification: notification,
            onTap: notification.isRead
                ? null
                : () => context
                    .read<NotificationsCubit>()
                    .markAsRead(notification.id),
            onMarkAsRead: notification.isRead
                ? null
                : () => context
                    .read<NotificationsCubit>()
                    .markAsRead(notification.id),
          );
        },
      ),
    );
  }
}

//! ===== Sub-Widgets =====

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.s, required this.theme});

  final S s;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    // Only shown by explicit check — reserved for future offline detection
    return const SizedBox.shrink();
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.isUnreadFilter,
    required this.s,
    required this.theme,
  });

  final bool isUnreadFilter;
  final S s;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 72.r,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            SizedBox(height: 16.h),
            Text(
              isUnreadFilter ? s.noUnreadNotifications : s.noNotifications,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (!isUnreadFilter) ...{
              SizedBox(height: 8.h),
              Text(
                s.noNotificationsDesc,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            },
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.s,
    required this.onRetry,
  });

  final String message;
  final S s;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 72.r,
              color: theme.colorScheme.error.withValues(alpha: 0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            FilledButton.tonal(
              onPressed: onRetry,
              child: Text(s.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginationLoader extends StatelessWidget {
  const _PaginationLoader({required this.state});

  final NotificationsState state;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Center(
        child: state.status == NotificationsStatus.paginationLoading
            ? const CircularProgressIndicator()
            : const SizedBox.shrink(),
      ),
    );
  }
}
