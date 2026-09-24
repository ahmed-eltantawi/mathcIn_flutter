import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/widgets/social_login_button.dart';
import 'package:MatchIn/features/auth/presentation/pages/register_view.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = S.of(context);

    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(locale.or, style: theme.textTheme.bodyMedium),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        SizedBox(height: 16.h),
        SocialLoginButton(
          text: locale.registerWithGoogle,
          icon: const Icon(Icons.g_mobiledata, size: 32),
          onPressed: () {},
        ),
        SizedBox(height: 32.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(locale.newHere, style: theme.textTheme.bodyMedium),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterView()),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Text(
                  locale.createAccount,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
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
            onPressed: () => context.go(AppRoutes.kHomeView),
            icon: Icon(
              Icons.explore_outlined,
              size: 22.sp,
              color: theme.colorScheme.primary,
            ),
            label: Text(
              locale.continueAsGuest,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor:
                  theme.colorScheme.primary.withValues(alpha: 0.08),
              side: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.4),
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