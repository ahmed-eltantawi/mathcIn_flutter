import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/widgets/custom_app_bar.dart';
import 'package:MatchIn/core/widgets/custom_button.dart';
import 'package:MatchIn/core/widgets/custom_snack_bar.dart';
import 'package:MatchIn/features/auth/presentation/cubit/reset_password_cubit.dart';
import 'package:MatchIn/features/auth/presentation/cubit/reset_password_state.dart';
import 'package:MatchIn/features/auth/presentation/widgets/create_password_back_button.dart';
import 'package:MatchIn/features/auth/presentation/widgets/create_password_form_card.dart';
import 'package:MatchIn/features/auth/presentation/widgets/create_password_header.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CreateNewPasswordView extends StatefulWidget {
  const CreateNewPasswordView({super.key, this.email = 'user@example.com'});

  final String email;

  @override
  State<CreateNewPasswordView> createState() => _CreateNewPasswordViewState();
}

class _CreateNewPasswordViewState extends State<CreateNewPasswordView> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_passwordController.text);
  bool get _hasSpecialChar =>
      RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_passwordController.text);
  bool get _isPasswordMatching =>
      _passwordController.text.isNotEmpty &&
      _passwordController.text == _confirmPasswordController.text;

  bool get _isValid =>
      _hasMinLength && _hasNumber && _hasSpecialChar && _isPasswordMatching;

  void _onSubmit() {
    if (!_isValid) {
      if (!_isPasswordMatching) {
        CustomSnackBar.showError(
          context,
          message: S.of(context).passwordsDoNotMatch,
        );
      }
      return;
    }

    context.read<ResetPasswordCubit>().resetPassword(
      email: widget.email,
      newPassword: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
      listener: (context, state) {
        if (state is ResetPasswordSuccess) {
          context.go(AppRoutes.kPasswordChangedSuccessView);
        } else if (state is ResetPasswordError) {
          CustomSnackBar.showError(context, message: state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is ResetPasswordLoading;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: CustomAppBar(title: S.of(context).createNewPassword),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CreatePasswordHeader(),
                  SizedBox(height: 24.h),
                  CreatePasswordFormCard(
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    hasMinLength: _hasMinLength,
                    hasNumber: _hasNumber,
                    hasSpecialChar: _hasSpecialChar,
                  ),
                  SizedBox(height: 24.h),
                  CustomButton(
                    text: S.of(context).resetPassword,
                    onPressed: _onSubmit,
                    isLoading: isLoading,
                  ),
                  SizedBox(height: 12.h),
                  CreatePasswordBackButton(
                    onPressed: () => context.go(AppRoutes.kLoginView),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
