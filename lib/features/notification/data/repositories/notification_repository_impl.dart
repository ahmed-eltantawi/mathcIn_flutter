import 'package:dartz/dartz.dart';
import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/features/notification/data/datasources/notification_local_data_source.dart';
import 'package:MatchIn/features/notification/data/datasources/notification_remote_data_source.dart';
import 'package:MatchIn/features/notification/data/models/notification_model.dart';
import 'package:MatchIn/features/notification/domain/entities/notification_entity.dart';
import 'package:MatchIn/features/notification/domain/entities/paginated_notifications_entity.dart';
import 'package:MatchIn/features/notification/domain/repositories/notification_repository.dart';
import 'package:MatchIn/features/notification/domain/services/notification_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  const NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.notificationService,
  });

  final NotificationRemoteDataSource remoteDataSource;
  final NotificationLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final NotificationService notificationService;

  @override
  Future<Either<Failure, PaginatedNotificationsEntity>> getNotifications({
    int page = 1,
    int perPage = 15,
    bool? unreadOnly,
  }) async {
    final isOnline = await networkInfo.isConnected;

    if (isOnline) {
      try {
        final remotePaginated = await remoteDataSource.getNotifications(
          page: page,
          perPage: perPage,
          unreadOnly: unreadOnly,
        );

        final models = remotePaginated.notifications
            .whereType<NotificationModel>()
            .toList();

        if (page == 1) {
          await localDataSource.saveNotifications(
            models,
            replace: unreadOnly != true,
          );
        } else {
          await localDataSource.saveNotifications(models, replace: false);
        }

        final unreadCount = await localDataSource.getCachedUnreadCount();
        notificationService.updateUnreadCount(unreadCount);

        return Right(remotePaginated);
      } on ServerException catch (e) {
        if (page == 1) {
          final cached = await localDataSource.getCachedNotifications(
            unreadOnly: unreadOnly,
          );
          if (cached.isNotEmpty) {
            return Right(
              PaginatedNotificationsEntity(
                notifications: cached,
                currentPage: 1,
                lastPage: 1,
                total: cached.length,
                hasMorePages: false,
              ),
            );
          }
        }
        return Left(ServerFailure(message: e.errorModel.errorMessage));
      } catch (e) {
        if (page == 1) {
          final cached = await localDataSource.getCachedNotifications(
            unreadOnly: unreadOnly,
          );
          if (cached.isNotEmpty) {
            return Right(
              PaginatedNotificationsEntity(
                notifications: cached,
                currentPage: 1,
                lastPage: 1,
                total: cached.length,
                hasMorePages: false,
              ),
            );
          }
        }
        return Left(ServerFailure(message: e.toString()));
      }
    } else {
      final cached = await localDataSource.getCachedNotifications(
        unreadOnly: unreadOnly,
      );

      if (cached.isNotEmpty) {
        final unreadCount = cached.where((n) => !n.isRead).length;
        notificationService.updateUnreadCount(unreadCount);

        return Right(
          PaginatedNotificationsEntity(
            notifications: cached,
            currentPage: 1,
            lastPage: 1,
            total: cached.length,
            hasMorePages: false,
          ),
        );
      }

      return const Left(OfflineFailure());
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    final isOnline = await networkInfo.isConnected;

    if (isOnline) {
      try {
        final count = await remoteDataSource.getUnreadCount();
        await localDataSource.saveUnreadCount(count);
        notificationService.updateUnreadCount(count);
        return Right(count);
      } catch (_) {
        final cached = await localDataSource.getCachedUnreadCount();
        notificationService.updateUnreadCount(cached);
        return Right(cached);
      }
    } else {
      final cached = await localDataSource.getCachedUnreadCount();
      notificationService.updateUnreadCount(cached);
      return Right(cached);
    }
  }

  @override
  Future<Either<Failure, NotificationEntity>> markNotificationAsRead({
    required int id,
  }) async {
    final localUpdated =
        await localDataSource.markNotificationAsReadLocally(id);
    final currentUnread = await localDataSource.getCachedUnreadCount();
    notificationService.updateUnreadCount(currentUnread);

    final isOnline = await networkInfo.isConnected;
    if (isOnline) {
      try {
        final remoteUpdated =
            await remoteDataSource.markNotificationAsRead(id: id);
        return Right(remoteUpdated);
      } catch (_) {
        if (localUpdated != null) {
          return Right(localUpdated);
        }
        return Right(
          NotificationEntity(
            id: id,
            type: 'notification',
            title: '',
            message: '',
            isRead: true,
            readAt: DateTime.now().toIso8601String(),
          ),
        );
      }
    }

    return Right(
      localUpdated ??
          NotificationEntity(
            id: id,
            type: 'notification',
            title: '',
            message: '',
            isRead: true,
            readAt: DateTime.now().toIso8601String(),
          ),
    );
  }

  @override
  Future<Either<Failure, int>> markAllNotificationsAsRead() async {
    final localCount =
        await localDataSource.markAllNotificationsAsReadLocally();
    notificationService.updateUnreadCount(0);

    final isOnline = await networkInfo.isConnected;
    if (isOnline) {
      try {
        final remoteCount =
            await remoteDataSource.markAllNotificationsAsRead();
        return Right(remoteCount);
      } catch (_) {
        return Right(localCount);
      }
    }

    return Right(localCount);
  }
}
