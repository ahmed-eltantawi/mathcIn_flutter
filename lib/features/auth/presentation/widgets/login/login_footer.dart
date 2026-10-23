import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class LoginFooterInner extends StatelessWidget {
  const LoginFooterInner({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class LoginFooterOuter extends StatelessWidget {
  const LoginFooterOuter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.colors;
    final locale = S.of(context);

    final isDark = theme.brightness == Brightness.dark;
    final guestColor = colors.primary;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: colors.outline),
          ),
          child: Row(
            children: [
              Icon(
                Icons.verified_user_outlined,
                color: isDark ? colors.secondary : colors.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  locale.secureProtectionText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              locale.newHere,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            InkWell(
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.push(AppRoutes.kRegisterView);
                }
              },
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Text(
                  locale.createAccount,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        SizedBox(
          width: double.infinity,
          height: 56.h,
          child: OutlinedButton.icon(
            onPressed: () async {
              await getIt<SharedPreferencesService>().setGuest(true);
              if (context.mounted) {
                context.go(AppRoutes.kHomeView);
              }
            },
            icon: Icon(
              Icons.explore_outlined,
              size: 22.sp,
              color: guestColor,
            ),
            label: Text(
              locale.continueAsGuest,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: guestColor,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: guestColor,
              backgroundColor: colors.primary.withValues(alpha: isDark ? 0.12 : 0.08),
              side: BorderSide(
                color: colors.primary.withValues(alpha: isDark ? 0.35 : 0.4),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
