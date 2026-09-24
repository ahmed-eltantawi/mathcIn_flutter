import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:MatchIn/generated/l10n.dart';

class ChatHistoryEmptyState extends StatelessWidget {
  const ChatHistoryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 48.r,
            color: theme.hintColor.withValues(alpha: 0.4),
          ),
          SizedBox(height: 12.h),
          Text(
            s.noConversationsYet,
            style: TextStyle(
              color: theme.hintColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
