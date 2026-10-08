import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/extensions/snack_bar_extensions.dart';
import '../../domain/entities/chat_message_entity.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
  });

  final ChatMessageEntity message;

  bool get _isUser => message.sender == MessageSender.user;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userBgColor = colors.primary;
    final aiBgColor = isDark
        ? colors.surfaceContainerHighest.withValues(alpha: 0.55)
        : colors.surfaceContainerHighest.withValues(alpha: 0.4);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Row(
        mainAxisAlignment:
            _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isUser) ...[
            Container(
              padding: EdgeInsets.all(7.r),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 16.r,
                color: colors.primary,
              ),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 15.w,
                vertical: 11.h,
              ),
              decoration: BoxDecoration(
                color: message.isError
                    ? colors.error.withValues(alpha: 0.1)
                    : (_isUser ? userBgColor : aiBgColor),
                borderRadius: BorderRadiusDirectional.only(
                  topStart: Radius.circular(18.r),
                  topEnd: Radius.circular(18.r),
                  bottomStart: Radius.circular(_isUser ? 18.r : 4.r),
                  bottomEnd: Radius.circular(_isUser ? 4.r : 18.r),
                ),
                border: message.isError
                    ? Border.all(
                        color: colors.error.withValues(alpha: 0.5),
                        width: 1.w,
                      )
                    : Border.all(
                        color: _isUser
                            ? Colors.transparent
                            : colors.outlineVariant.withValues(
                                alpha: isDark ? 0.2 : 0.35,
                              ),
                        width: 1.w,
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    message.content,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: message.isError
                          ? colors.error
                          : (_isUser ? colors.onPrimary : colors.onSurface),
                      fontSize: 14.5.sp,
                      height: 1.4,
                    ),
                  ),
                  if (!_isUser && !message.isError) ...[
                    SizedBox(height: 6.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(6.r),
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: message.content),
                            );
                            context.showSuccessSnackBar(
                              l10n.copiedToClipboard,
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 2.h,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.copy_rounded,
                                  size: 13.r,
                                  color: colors.onSurfaceVariant.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  l10n.copy,
                                  style: context.textTheme.bodySmall?.copyWith(
                                    fontSize: 11.5.sp,
                                    color: colors.onSurfaceVariant.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
                color: colors.secondary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_rounded,
                size: 16.r,
                color: colors.secondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
