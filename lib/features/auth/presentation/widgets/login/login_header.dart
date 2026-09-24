import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/generated/l10n.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = S.of(context);

    return Column(
      children: [
        Image.asset('assets/images/app_icon.png', height: 80.h),
        SizedBox(height: 16.h),
        Text(
          locale.welcomeBack,
          style: theme.textTheme.headlineSmall,
        ),
        SizedBox(height: 8.h),
        Text(
          locale.smartCareerDiscoveryPlatform,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}