import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/utils/app_text_styles.dart';
import 'package:MatchIn/core/widgets/custom_button.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class PasswordChangedSuccessView extends StatelessWidget {
  const PasswordChangedSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Soft Circular Success Container
              Container(
                width: 88.w,
                height: 88.w,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.check_rounded,
                  size: 38.sp,
                  color: colors.primary,
                ),
              ),
              SizedBox(height: 24.h),

              // Headline
              Text(
                S.of(context).passwordChangedSuccessfully,
                textAlign: TextAlign.center,
                style: AppTextStyles.heading24Bold(
                  isArabic: false,
                  color: colors.onSurface,
                ),
              ),
              SizedBox(height: 12.h),

              // Supporting Text
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Text(
                  S.of(context).passwordChangedSuccessDesc,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body14Regular(
                    isArabic: false,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),

              const Spacer(flex: 2),

              // Primary Action
              CustomButton(
                text: S.of(context).backToLogin,
                onPressed: () => context.go(AppRoutes.kLoginView),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
