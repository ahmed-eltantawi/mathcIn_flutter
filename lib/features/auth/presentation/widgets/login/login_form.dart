import 'package:MatchIn/core/widgets/custom_button.dart';
import 'package:MatchIn/core/widgets/custom_text_field.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/core/utils/validator.dart';
import 'package:MatchIn/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:MatchIn/core/routing/app_routes.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final ValueNotifier<bool> _isKeepSignedIn;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _isKeepSignedIn = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _isKeepSignedIn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = S.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: _emailController,
            labelText: locale.email,
            hintText: locale.emailHint,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: Validator.validateEmail,
          ),
          SizedBox(height: 16.h),
          CustomTextField(
            controller: _passwordController,
            labelText: locale.password,
            hintText: locale.passwordHint,
            isPassword: true,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty)
                return locale.passwordRequirements;
              return null;
            },
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: _isKeepSignedIn,
                    builder: (context, value, child) {
                      return Switch(
                        value: value,
                        activeColor: AppColors.white,
                        activeTrackColor: AppColors.midnightBlue,
                        inactiveTrackColor: AppColors.surfaceVariant,
                        onChanged: (newValue) =>
                            _isKeepSignedIn.value = newValue,
                      );
                    },
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locale.keepMeSignedIn,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        locale.onlyOnTrustedDevices,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                child: Text(
                  locale.forgotPassword,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.terracotta,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is LoginSuccess) {
                context.go(AppRoutes.kHomeView);
              } else if (state is LoginFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              return state is LoginLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: locale.login,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthCubit>().login(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                          }
                        },
                      ),
                    );
            },
          ),
        ],
      ),
    );
  }
}
