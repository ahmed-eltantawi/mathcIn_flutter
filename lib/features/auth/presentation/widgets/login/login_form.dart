import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/widgets/custom_button.dart';
import 'package:MatchIn/core/widgets/custom_text_field.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:MatchIn/core/utils/validator.dart';
import 'package:MatchIn/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:MatchIn/features/auth/presentation/helpers/auth_success_handler.dart';
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
    final theme = context.theme;
    final colors = context.colors;
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
              if (value == null || value.isEmpty) {
                return locale.passwordRequirements;
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    ValueListenableBuilder<bool>(
                      valueListenable: _isKeepSignedIn,
                      builder: (context, value, child) {
                        return Switch(
                          value: value,
                          activeThumbColor: colors.surface,
                          activeTrackColor: colors.primary,
                          inactiveTrackColor: colors.surfaceContainerHighest,
                          onChanged: (newValue) =>
                              _isKeepSignedIn.value = newValue,
                        );
                      },
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locale.keepMeSignedIn,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            locale.onlyOnTrustedDevices,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  final email = _emailController.text.trim();
                  context.push(
                    AppRoutes.kForgetPasswordView,
                    extra: email.isNotEmpty ? email : null,
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  locale.forgotPassword,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) async {
              if (state is LoginSuccess) {
                await handleLoginSuccess(context, state.loginModel);
              } else if (state is LoginFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: colors.error,
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
