import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/features/auth/presentation/widgets/register/register_footer.dart';
import 'package:MatchIn/features/auth/presentation/widgets/register/register_form.dart';
import 'package:MatchIn/features/auth/presentation/widgets/register/register_header.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.kLoginView);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.colors;
    final locale = S.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handleBack(context);
        }
      },
      child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colors.onSurface),
              onPressed: () => _handleBack(context),
            ),
            title: Text(
              locale.createAccount,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              children: [
                const RegisterHeader(),
                SizedBox(height: 32.h),
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: colors.outline),
                  ),
                  child: Column(
                    children: [
                      const RegisterForm(),
                      SizedBox(height: 16.h),
                      const RegisterFooter(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }
}
