import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationsHeader extends StatelessWidget {
  const NotificationsHeader({
    super.key,
    this.onMarkAllRead,
  });

  final VoidCallback? onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              S.of(context).notifications,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(
            onPressed: onMarkAllRead ?? () {},
            child: Text(S.of(context).markAllRead),
          ),
        ],
      ),
    );
  }
}
