import 'package:MatchIn/core/widgets/custom_button.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:MatchIn/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RegisterSubmitButton extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController nameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final ValueNotifier<bool> isTermsAccepted;

  const RegisterSubmitButton({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.nameController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isTermsAccepted,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          context.push(
            AppRoutes.kOtpVerificationView,
            extra: emailController.text,
          );
        } else if (state is RegisterFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
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
                        email: emailController.text,
                        name: nameController.text,
                        password: passwordController.text,
                        passwordConfirmation: confirmPasswordController.text,
                      );
                    } else if (!isTermsAccepted.value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(S.of(context).termsAndConditions),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                ),
              );
      },
    );
  }
}
