import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/extensions/snack_bar_extensions.dart';
import '../../domain/entities/chat_message_entity.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    this.onRetry,
    this.onSelectPrompt,
  });

  final ChatMessageEntity message;
  final VoidCallback? onRetry;
  final ValueChanged<String>? onSelectPrompt;

  bool get _isUser => message.sender == MessageSender.user;

  String _formatTime(DateTime time) {
    try {
      return DateFormat('hh:mm a').format(time);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userBgColor = colors.primary;
    final aiBgColor = isDark
        ? colors.surfaceContainerHighest.withValues(alpha: 0.55)
        : colors.surfaceContainerHighest.withValues(alpha: 0.4);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        child: Column(
          crossAxisAlignment:
              _isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_isUser) ...[
                  Container(
                    padding: EdgeInsets.all(7.r),
                    decoration: BoxDecoration(
                      color: message.isError
                          ? colors.error.withValues(alpha: 0.12)
                          : colors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      message.isError
                          ? Icons.error_outline_rounded
                          : Icons.auto_awesome_rounded,
                      size: 16.r,
                      color: message.isError ? colors.error : colors.primary,
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
                        SizedBox(height: 6.h),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTime(message.timestamp),
                              style: context.textTheme.bodySmall?.copyWith(
                                fontSize: 11.sp,
                                color: _isUser
                                    ? colors.onPrimary.withValues(alpha: 0.75)
                                    : colors.onSurfaceVariant.withValues(alpha: 0.7),
                              ),
                            ),
                            if (!_isUser && !message.isError) ...[
                              SizedBox(width: 10.w),
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
                                        style:
                                            context.textTheme.bodySmall?.copyWith(
                                          fontSize: 11.sp,
                                          color:
                                              colors.onSurfaceVariant.withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            if (message.isError && onRetry != null) ...[
                              SizedBox(width: 8.w),
                              InkWell(
                                borderRadius: BorderRadius.circular(6.r),
                                onTap: onRetry,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                    vertical: 2.h,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.refresh_rounded,
                                        size: 14.r,
                                        color: colors.error,
                                      ),
                                      SizedBox(width: 3.w),
                                      Text(
                                        l10n.retry,
                                        style:
                                            context.textTheme.bodySmall?.copyWith(
                                          fontSize: 11.5.sp,
                                          fontWeight: FontWeight.bold,
                                          color: colors.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
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
            // Render interactive suggested actions chips underneath AI reply
            if (!_isUser &&
                !message.isError &&
                message.suggestedActions.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsetsDirectional.only(start: 32.w),
                child: Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: message.suggestedActions.map((action) {
                    return ActionChip(
                      avatar: Icon(
                        Icons.auto_awesome_outlined,
                        size: 14.r,
                        color: colors.primary,
                      ),
                      label: Text(
                        action.label,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: colors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: colors.primary.withValues(alpha: 0.08),
                      side: BorderSide(
                        color: colors.primary.withValues(alpha: 0.25),
                        width: 1.w,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      onPressed: onSelectPrompt != null
                          ? () => onSelectPrompt!(action.label)
                          : null,
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
