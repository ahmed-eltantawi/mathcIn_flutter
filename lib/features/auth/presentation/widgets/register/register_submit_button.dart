import 'package:MatchIn/core/extensions/snack_bar_extensions.dart';
import 'package:MatchIn/core/widgets/custom_button.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:MatchIn/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RegisterSubmitButton extends StatelessWidget {
  const RegisterSubmitButton({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.nameController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isTermsAccepted,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController nameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final ValueNotifier<bool> isTermsAccepted;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          if (state.otpSent) {
            context.showSuccessSnackBar(
              S.of(context).verificationCodeSentToEmail,
            );
          } else {
            context.showErrorSnackBar(state.otpSendError!);
          }
          context.push(
            AppRoutes.kOtpVerificationView,
            extra: <String, dynamic>{
              'email': emailController.text.trim(),
              'allowImmediateResend': !state.otpSent,
            },
          );
        } else if (state is RegisterFailure) {
          context.showErrorSnackBar(state.message);
        }
      },
      builder: (context, state) {
        return state is RegisterLoading
            ? const Center(child: CircularProgressIndicator())
            : SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: S.of(context).completeRegistration,
                  onPressed: () {
                    if (formKey.currentState!.validate() &&
                        isTermsAccepted.value) {
                      context.read<AuthCubit>().register(
                        email: emailController.text.trim(),
                        name: nameController.text.trim(),
                        password: passwordController.text,
                        passwordConfirmation: confirmPasswordController.text,
                      );
                    } else if (!isTermsAccepted.value) {
                      context.showErrorSnackBar(S.of(context).termsAndConditions);
                    }
                  },
                ),
              );
      },
    );
  }
}
