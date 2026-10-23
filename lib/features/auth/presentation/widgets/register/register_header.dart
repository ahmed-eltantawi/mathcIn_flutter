import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/utils/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/generated/l10n.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final locale = S.of(context);

    return Column(
      children: [
        Image.asset(Assets.appIcon, height: 80.h),
        SizedBox(height: 16.h),
        Text(
          locale.smartCareerDiscoveryPlatform,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
