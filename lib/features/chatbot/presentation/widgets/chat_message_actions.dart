import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:MatchIn/features/chatbot/presentation/cubit/chatbot_cubit.dart';
import 'package:MatchIn/generated/l10n.dart';

class ChatMessageActions extends StatelessWidget {
  const ChatMessageActions({
    super.key,
    required this.messageContent,
    required this.isLastAiMessage,
  });

  final String messageContent;
  final bool isLastAiMessage;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Copy Action
        InkWell(
          onTap: () {
            Clipboard.setData(
              ClipboardData(text: messageContent),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(s.copiedToClipboard),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          borderRadius: BorderRadius.circular(6.r),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 6.w,
              vertical: 2.h,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.copy_rounded,
                  size: 13.r,
                  color: theme.hintColor,
                ),
                SizedBox(width: 4.w),
                Text(
                  s.copy,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: theme.hintColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isLastAiMessage) ...[
          SizedBox(width: 12.w),
          // Regenerate Action
          InkWell(
            onTap: () {
              context.read<ChatbotCubit>().regenerateLastMessage();
            },
            borderRadius: BorderRadius.circular(6.r),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 6.w,
                vertical: 2.h,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    size: 13.r,
                    color: theme.hintColor,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    s.regenerate,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      color: theme.hintColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
