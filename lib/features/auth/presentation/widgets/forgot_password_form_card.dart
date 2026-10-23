import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/utils/validator.dart';
import 'package:MatchIn/core/widgets/custom_text_field.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ForgotPasswordFormCard extends StatelessWidget {
  const ForgotPasswordFormCard({
    super.key,
    required this.formKey,
    required this.emailController,
    this.onFieldSubmitted,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colors;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.outline,
          width: 1,
        ),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: emailController,
              labelText: S.of(context).email,
              hintText: S.of(context).emailHint,
              prefixIcon: Icon(
                Icons.mail_outline_rounded,
                size: 20.sp,
                color: colorScheme.onSurfaceVariant,
              ),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              validator: Validator.validateEmail,
            ),
          ],
        ),
      ),
    );
  }
}
