import 'package:MatchIn/features/notification/domain/entities/notification_entity.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
  });

  final NotificationEntity notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;

  ///* Maps notification type to a suitable icon.
  static IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'job':
      case 'job_match':
      case 'new_job':
        return Icons.work_outline;
      case 'roadmap':
      case 'roadmap_update':
        return Icons.route_outlined;
      case 'cv':
      case 'cv_analysis':
        return Icons.description_outlined;
      case 'application':
      case 'application_status':
        return Icons.assignment_turned_in_outlined;
      case 'system':
      case 'general':
      default:
        return Icons.notifications_outlined;
    }
  }

  ///* Formats the createdAt ISO string into a human-readable relative time.
  static String _formatTime(BuildContext context, String? createdAt) {
    if (createdAt == null) return '';
    final s = S.of(context);

    try {
      final created = DateTime.parse(createdAt).toLocal();
      final now = DateTime.now();
      final diff = now.difference(created);

      if (diff.inSeconds < 60) return s.justNow;
      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays == 1) return s.yesterday;
      if (diff.inDays < 7) return '${diff.inDays}d';
      return '${(diff.inDays / 7).floor()}w';
    } catch (_) {
      return createdAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    final icon = _iconForType(notification.type);
    final timeLabel = _formatTime(context, notification.createdAt);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(14.r),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //! ─── Icon Badge ───────
              Container(
                width: 48.w,
                height: 48.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                ),
              ),

              SizedBox(width: 12.w),

              //! ─── Content ───────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //! Title row + unread dot
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!notification.isRead) ...{
                          SizedBox(width: 8.w),
                          Container(
                            width: 8.r,
                            height: 8.r,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        },
                      ],
                    ),

                    SizedBox(height: 6.h),

                    //! Message
                    Text(
                      notification.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),

                    SizedBox(height: 12.h),
                    const Divider(height: 1),
                    SizedBox(height: 8.h),

                    //! Footer: time + mark as read action
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            timeLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ),
                        if (!notification.isRead && onMarkAsRead != null)
                          TextButton(
                            onPressed: onMarkAsRead,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(s.markAsRead),
                                SizedBox(width: 4.w),
                                const Icon(
                                  Icons.done_all_rounded,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
