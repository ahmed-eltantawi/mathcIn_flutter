import 'package:MatchIn/core/widgets/custom_button.dart';
import 'package:MatchIn/core/widgets/custom_snack_bar.dart';
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
          context.push(
            AppRoutes.kOtpVerificationView,
            extra: emailController.text,
          );
        } else if (state is RegisterFailure) {
          CustomSnackBar.showError(context, message: state.message);
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
                    // 1. ننزل الكيبورد عشان اليوزر يشوف الـ UI براحته
                    FocusScope.of(context).unfocus();

                    // 2. نشيك على الحقول الأول
                    final isValid = formKey.currentState?.validate() ?? false;

                    // 3. نشيك على الشروط والأحكام
                    if (!isTermsAccepted.value) {
                      CustomSnackBar.showError(
                        context,
                        message: S.of(context).termsAndConditions,
                      );
                      return; // نوقف الكود هنا وميكملش
                    }

                    // 4. لو كله تمام (الحقول صح والشروط متوافق عليها)، ننده الـ API
                    if (isValid) {
                      context.read<AuthCubit>().register(
                        email: emailController.text,
                        name: nameController.text,
                        password: passwordController.text,
                        passwordConfirmation: confirmPasswordController.text,
                      );
                    }
                  },
                ),
              );
      },
    );
  }
}
