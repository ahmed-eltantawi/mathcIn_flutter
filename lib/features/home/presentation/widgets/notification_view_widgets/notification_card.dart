import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
    required this.actionLabel,
    this.isUnread = false,
    this.onTap,
    this.onActionTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final String time;
  final String actionLabel;
  final bool isUnread;
  final VoidCallback? onTap;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              Container(
                width: 48.w,
                height: 48.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: theme
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                          ),
                        ),
                        if (isUnread) ...[
                          SizedBox(width: 8.w),
                          Container(
                            width: 8.r,
                            height: 8.r,
                            decoration: BoxDecoration(
                              color: theme
                                  .colorScheme
                                  .secondary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(
                            color: theme
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                    SizedBox(height: 12.h),
                    const Divider(height: 1),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            time,
                            style: theme.textTheme.bodySmall
                                ?.copyWith(
                                  color: theme
                                      .colorScheme
                                      .onSurface
                                      .withValues(
                                        alpha: 0.6,
                                      ),
                                ),
                          ),
                        ),
                        TextButton(
                          onPressed: onActionTap ?? () {},
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(actionLabel),
                              SizedBox(width: 4.w),
                              const Icon(
                                Icons.arrow_forward,
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
