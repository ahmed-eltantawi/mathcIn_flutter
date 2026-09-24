import 'package:MatchIn/core/widgets/custom_button.dart';
import 'package:MatchIn/core/widgets/custom_text_field.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginForm extends StatelessWidget {
  LoginForm({super.key});

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ValueNotifier<bool> _isKeepSignedIn = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = S.of(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
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
            textInputAction: TextInputAction.done,
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
                        activeThumbColor: theme.colorScheme.primary,
                        onChanged: (newValue) {
                          _isKeepSignedIn.value = newValue;
                        },
                      );
                    },
                  ),
                  Text(
                    locale.keepMeSignedIn,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  locale.forgotPassword,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          CustomButton(
            text: locale.login,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // TODO: Call Cubit method here
              }
            },
          ),
        ],
      ),
    );
  }
}
