import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/home/presentation/widgets/notification_view_widgets/notifications_view_body.dart';
import 'package:MatchIn/features/notification/presentation/cubit/notifications_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NotificationsCubit>(
      create: (_) => getIt<NotificationsCubit>()..loadNotifications(),
      child: const Scaffold(
        body: SafeArea(child: NotificationsViewBody()),
      ),
    );
  }
}
