import 'package:MatchIn/core/widgets/custom_button.dart';
import 'package:MatchIn/core/widgets/custom_text_field.dart';
import 'package:MatchIn/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterForm extends StatelessWidget {
  RegisterForm({super.key});

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ValueNotifier<bool> _isTermsAccepted = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = S.of(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _nameController,
            labelText: locale.name,
            hintText: locale.nameHint,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return locale.name;
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          CustomTextField(
            controller: _emailController,
            labelText: locale.email,
            hintText: locale.emailHint,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return locale.email;
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return locale.email;
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          CustomTextField(
            controller: _passwordController,
            labelText: locale.password,
            hintText: locale.passwordHint,
            isPassword: true,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return locale.password;
              }
              if (value.length < 6) {
                return locale.password;
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          CustomTextField(
            controller: _confirmPasswordController,
            labelText: locale.confirmPassword,
            hintText: locale.confirmPasswordHint,
            isPassword: true,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return locale.confirmPassword;
              }
              if (value != _passwordController.text) {
                return locale.confirmPassword;
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: _isTermsAccepted,
                builder: (context, value, child) {
                  return Checkbox(
                    value: value,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (newValue) =>
                        _isTermsAccepted.value = newValue ?? false,
                  );
                },
              ),
              Expanded(
                child: Text(
                  locale.termsAndConditions,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {},
            builder: (context, state) {
              return state is RegisterLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      text: locale.completeRegistration,
                      onPressed: () {
                        if (_formKey.currentState!.validate() &&
                            _isTermsAccepted.value) {
                          context.read<AuthCubit>().register(
                            email: _emailController.text,
                            name: _nameController.text,
                            password: _passwordController.text,
                            passwordConfirmation:
                                _confirmPasswordController.text,
                          );
                        } else if (!_isTermsAccepted.value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please accept terms'),
                            ),
                          );
                        }
                      },
                    );
            },
          ),
        ],
      ),
    );
  }
}
