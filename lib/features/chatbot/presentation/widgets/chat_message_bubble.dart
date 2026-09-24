import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:MatchIn/features/chatbot/domain/entities/chat_message_entity.dart';
import 'package:MatchIn/features/chatbot/presentation/widgets/chat_message_actions.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    this.isLastAiMessage = false,
  });

  final ChatMessageEntity message;
  final bool isLastAiMessage;

  bool get _isUser => message.sender == MessageSender.user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final userBgColor = theme.primaryColor;
    final aiBgColor = isDark
        ? Colors.grey[850]!
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Row(
        mainAxisAlignment: _isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isUser) ...[
            Container(
              padding: EdgeInsets.all(7.r),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 16.r,
                color: theme.primaryColor,
              ),
            ),
            SizedBox(width: 8.w),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 0.78.sw),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: message.isError
                    ? Colors.red.withValues(alpha: 0.1)
                    : (_isUser ? userBgColor : aiBgColor),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                  bottomLeft: Radius.circular(_isUser ? 16.r : 4.r),
                  bottomRight: Radius.circular(_isUser ? 4.r : 16.r),
                ),
                border: message.isError
                    ? Border.all(color: Colors.red.shade300, width: 1)
                    : (isDark && !_isUser
                          ? Border.all(color: Colors.grey[750]!, width: 1)
                          : null),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isUser)
                    SelectableText(
                      message.content,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.5.sp,
                        height: 1.4,
                      ),
                    )
                  else if (message.isError)
                    SelectableText(
                      message.content,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14.sp,
                        height: 1.4,
                      ),
                    )
                  else
                    MarkdownBody(
                      data: message.content,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                        p: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14.5.sp,
                          height: 1.45,
                          color: isDark
                              ? Colors.grey[200]
                              : theme.textTheme.bodyLarge?.color,
                        ),
                        h1: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                        h2: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        h3: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        code: TextStyle(
                          fontSize: 13.sp,
                          fontFamily: 'monospace',
                          backgroundColor: isDark
                              ? Colors.black26
                              : Colors.black.withValues(alpha: 0.05),
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: isDark ? Colors.grey[900] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        listBullet: TextStyle(
                          fontSize: 14.5.sp,
                          color: theme.primaryColor,
                        ),
                      ),
                    ),
                  if (!_isUser && !message.isError) ...[
                    SizedBox(height: 8.h),
                    ChatMessageActions(
                      messageContent: message.content,
                      isLastAiMessage: isLastAiMessage,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (_isUser) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.all(7.r),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                size: 16.r,
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
