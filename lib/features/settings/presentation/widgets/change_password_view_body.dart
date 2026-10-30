import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/extensions/snack_bar_extensions.dart';
import 'package:MatchIn/core/utils/app_strings.dart';
import 'package:MatchIn/core/utils/validator.dart';
import 'package:MatchIn/core/widgets/custom_button.dart';
import 'package:MatchIn/core/widgets/custom_text_field.dart';
import 'package:MatchIn/features/settings/presentation/cubit/change_password_cubit.dart';
import 'package:MatchIn/features/settings/presentation/cubit/change_password_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ChangePasswordViewBody extends StatefulWidget {
  const ChangePasswordViewBody({super.key});

  @override
  State<ChangePasswordViewBody> createState() => _ChangePasswordViewBodyState();
}

class _ChangePasswordViewBodyState extends State<ChangePasswordViewBody> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSubmit({required bool otpSent}) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cubit = context.read<ChangePasswordCubit>();
    if (otpSent) {
      cubit.confirmWithOtp(
        otp: _otpController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
    } else {
      cubit.requestOtp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = context.theme;
    final l10n = context.l10n;

    return BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
      listener: (context, state) {
        if (state is ChangePasswordOtpSent) {
          context.showSuccessSnackBar(l10n.verificationCodeSentToEmail);
        }
        if (state is ChangePasswordSuccess) {
          context.showSuccessSnackBar(l10n.changePasswordSuccess);
          context.pop();
        } else if (state is ChangePasswordFailure) {
          context.showErrorSnackBar(state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is ChangePasswordLoading;
        final otpSent =
            state is ChangePasswordOtpSent ||
            (state is ChangePasswordLoading && state.otpSent) ||
            (state is ChangePasswordFailure && state.otpSent);

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: colors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: colors.primary,
                        size: 20.sp,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          l10n.changePasswordDescription,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.8),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                if (otpSent) ...[
                  Text(
                    l10n.verificationCodeSentToEmail,
                    style: theme.textTheme.bodyMedium,
                  ),
                  SizedBox(height: 14.h),
                  CustomTextField(
                    labelText: l10n.verificationCodeLabel,
                    hintText: l10n.enterVerificationCode,
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.mark_email_read_outlined),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? AppStrings.fieldRequired
                        : null,
                  ),
                  SizedBox(height: 18.h),
                ],

                CustomTextField(
                  labelText: l10n.newPassword,
                  hintText: '••••••••',
                  controller: _newPasswordController,
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_reset_rounded),
                  validator: Validator.validatePassword,
                ),

                SizedBox(height: 18.h),

                CustomTextField(
                  labelText: l10n.confirmNewPassword,
                  hintText: '••••••••',
                  controller: _confirmPasswordController,
                  isPassword: true,
                  prefixIcon: const Icon(Icons.check_circle_outline_rounded),
                  validator: (value) => Validator.validateConfirmPassword(
                    value,
                    _newPasswordController.text,
                  ),
                ),

                SizedBox(height: 36.h),

                CustomButton(
                  text: otpSent ? l10n.verify : l10n.sendVerificationCode,
                  isLoading: isLoading,
                  onPressed: () => _onSubmit(otpSent: otpSent),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
