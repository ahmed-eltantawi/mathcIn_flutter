import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:MatchIn/generated/l10n.dart';

class ChatSendButton extends StatelessWidget {
  const ChatSendButton({
    super.key,
    required this.canSend,
    required this.isGenerating,
    required this.onSend,
  });

  final bool canSend;
  final bool isGenerating;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isEnabled = canSend && !isGenerating;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 38.r,
      height: 38.r,
      decoration: BoxDecoration(
        color: isEnabled
            ? colorScheme.primary
            : colorScheme.onSurface.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: isEnabled ? onSend : null,
        padding: EdgeInsets.all(8.r),
        constraints: const BoxConstraints(),
        tooltip: s.verify,
        icon: isGenerating
            ? SizedBox(
                width: 16.r,
                height: 16.r,
                child: CircularProgressIndicator(
                  strokeWidth: 2.r,
                  color: colorScheme.onPrimary,
                ),
              )
            : Icon(
                Icons.arrow_upward_rounded,
                size: 18.r,
                color: isEnabled
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
              ),
      ),
    );
  }
}
