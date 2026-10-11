import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/extensions/snack_bar_extensions.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/widgets/custom_app_bar.dart';
import 'package:MatchIn/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:MatchIn/features/auth/presentation/widgets/forgot_password/forgot_password_back_button.dart';
import 'package:MatchIn/features/auth/presentation/widgets/forgot_password/forgot_password_form_card.dart';
import 'package:MatchIn/features/auth/presentation/widgets/forgot_password/forgot_password_header.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({
    super.key,
    this.initialEmail,
  });

  final String? initialEmail;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordSuccess) {
          context.push(
            AppRoutes.kOtpVerificationView,
            extra: {
              'email': state.email,
              'isPasswordReset': true,
            },
          );
        } else if (state is ForgotPasswordFailure) {
          context.showErrorSnackBar(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(title: context.l10n.forgotPasswordTitle),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ForgotPasswordHeader(),
                SizedBox(height: 24.h),
                ForgotPasswordFormCard(initialEmail: initialEmail),
                SizedBox(height: 24.h),
                ForgotPasswordBackButton(
                  onPressed: () => context.go(AppRoutes.kLoginView),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
