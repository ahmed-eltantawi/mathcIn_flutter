import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/errors/error_message_resolver.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';

/// Standard error display widget with action/retry button.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.retryText,
    this.icon,
  });

  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final String? retryText;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final effectiveTitle = title ?? context.l10n.somethingWentWrong;
    final effectiveRetryText = retryText ?? context.l10n.tryAgain;
    final effectiveMessage = ErrorMessageResolver.resolve(context, message);

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline_rounded,
              size: 48.r,
              color: context.colors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              effectiveTitle,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              effectiveMessage,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 20.h),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(effectiveRetryText),
                style: ElevatedButton.styleFrom(minimumSize: Size(140.w, 44.h)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
