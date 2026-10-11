import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/utils/validator.dart';
import 'package:MatchIn/core/widgets/custom_button.dart';
import 'package:MatchIn/core/widgets/custom_text_field.dart';
import 'package:MatchIn/features/auth/presentation/cubit/forgot_password_cubit.dart';

// StatefulWidget that encapsulates the TextEditingController and FormState
// away from the Cubit and the StatelessWidget parent view
class ForgotPasswordFormCard extends StatefulWidget {
  const ForgotPasswordFormCard({
    super.key,
    this.initialEmail,
  });

  final String? initialEmail;

  @override
  State<ForgotPasswordFormCard> createState() => _ForgotPasswordFormCardState();
}

class _ForgotPasswordFormCardState extends State<ForgotPasswordFormCard> {
  late final GlobalKey<FormState> _formKey;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<ForgotPasswordCubit>().sendResetCode(
      email: _emailController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final locale = context.l10n;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: theme.dividerColor, width: 1),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: _emailController,
              labelText: locale.email,
              hintText: locale.emailHint,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              validator: Validator.validateEmail,
            ),
            SizedBox(height: 24.h),
            BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
              builder: (context, state) {
                return CustomButton(
                  text: locale.sendResetCode,
                  onPressed: _onSubmit,
                  isLoading: state is ForgotPasswordLoading,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
