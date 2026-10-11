import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.colors;
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                Navigator.of(context).maybePop();
              }
            },
            icon: Transform.flip(
              flipX: Directionality.of(context) == TextDirection.rtl,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18.sp,
                color: colors.onSurface,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              l10n.settings,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),
          ),
          Icon(
            Icons.tune_rounded,
            color: colors.onSurface.withValues(alpha: 0.6),
            size: 22.sp,
          ),
        ],
      ),
    );
  }
}
