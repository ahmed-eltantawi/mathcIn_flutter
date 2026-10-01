import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OtpResendRow extends StatelessWidget {
  const OtpResendRow({
    super.key,
    required this.secondsRemaining,
    required this.enabled,
    required this.onResend,
  });

  final int secondsRemaining;
  final bool enabled;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isTimerActive = secondsRemaining > 0;
    final canTap = !isTimerActive && enabled;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isTimerActive
              ? '${S.of(context).resendCodeIn} $secondsRemaining${S.of(context).secondsSuffix}'
              : '',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        InkWell(
          onTap: canTap ? onResend : null,
          borderRadius: BorderRadius.circular(4.r),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 2.h,
            ),
            child: Text(
              S.of(context).resendCode,
              style: theme.textTheme.labelSmall?.copyWith(
                color: canTap
                    ? colorScheme.secondary
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
