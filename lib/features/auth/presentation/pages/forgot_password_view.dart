import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/extensions/snack_bar_extensions.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/widgets/custom_app_bar.dart';
import 'package:MatchIn/core/widgets/custom_button.dart';
import 'package:MatchIn/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:MatchIn/features/auth/presentation/cubit/forgot_password_state.dart';
import 'package:MatchIn/features/auth/presentation/pages/otp_verification_view.dart';
import 'package:MatchIn/features/auth/presentation/widgets/create_password_back_button.dart';
import 'package:MatchIn/features/auth/presentation/widgets/forgot_password_form_card.dart';
import 'package:MatchIn/features/auth/presentation/widgets/forgot_password_header.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({
    super.key,
    this.email,
  });

  final String? email;

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSendCodePressed() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text.trim();
      context.read<ForgotPasswordCubit>().sendForgotPasswordEmail(email: email);
    }
  }

  void _handleBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.kLoginView);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: S.of(context).forgotPassword,
          onBack: _handleBack,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 16.h,
            ),
            child: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
              listener: (context, state) {
                if (state is ForgotPasswordFailure) {
                  context.showErrorSnackBar(state.message);
                } else if (state is ForgotPasswordSuccess) {
                  context.showSuccessSnackBar(
                    locale.verificationCodeSentToEmail,
                  );
                  context.push(
                    AppRoutes.kOtpVerificationView,
                    extra: <String, dynamic>{
                      'email': _emailController.text.trim(),
                      'mode': OtpMode.passwordReset,
                    },
                  );
                }
              },
              builder: (context, state) {
                final isLoading = state is ForgotPasswordLoading;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ForgotPasswordHeader(),
                    SizedBox(height: 24.h),
                    ForgotPasswordFormCard(
                      formKey: _formKey,
                      emailController: _emailController,
                      onFieldSubmitted: (_) => _onSendCodePressed(),
                    ),
                    SizedBox(height: 24.h),
                    CustomButton(
                      text: locale.sendVerificationCode,
                      isLoading: isLoading,
                      onPressed: _onSendCodePressed,
                    ),
                    SizedBox(height: 16.h),
                    CreatePasswordBackButton(
                      onPressed: () => context.go(AppRoutes.kLoginView),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
