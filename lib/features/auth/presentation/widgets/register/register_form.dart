import 'package:MatchIn/core/widgets/custom_text_field.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:MatchIn/core/utils/validator.dart';
import 'package:MatchIn/features/auth/presentation/widgets/register/register_terms_checkbox.dart';
import 'package:MatchIn/features/auth/presentation/widgets/register/register_submit_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _emailController;
  late final TextEditingController _nameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final ValueNotifier<bool> _isTermsAccepted;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _nameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _isTermsAccepted = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _isTermsAccepted.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: _nameController,
            labelText: locale.fullName,
            hintText: locale.fullName,
            textInputAction: TextInputAction.next,
            validator: Validator.validateUserName,
          ),
          SizedBox(height: 16.h),
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
            textInputAction: TextInputAction.next,
            validator: Validator.validatePassword,
          ),
          SizedBox(height: 8.h),
          SizedBox(height: 16.h),
          CustomTextField(
            controller: _confirmPasswordController,
            labelText: locale.confirmPassword,
            hintText: locale.confirmPasswordHint,
            isPassword: true,
            textInputAction: TextInputAction.done,
            validator: (value) => Validator.validateConfirmPassword(
              value,
              _passwordController.text,
            ),
          ),
          SizedBox(height: 16.h),
          RegisterTermsCheckbox(isTermsAccepted: _isTermsAccepted),
          SizedBox(height: 24.h),
          RegisterSubmitButton(
            formKey: _formKey,
            emailController: _emailController,
            nameController: _nameController,
            passwordController: _passwordController,
            confirmPasswordController: _confirmPasswordController,
            isTermsAccepted: _isTermsAccepted,
          ),
        ],
      ),
    );
  }
}
