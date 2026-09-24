import 'package:MatchIn/core/widgets/custom_text_field.dart';
import 'package:MatchIn/features/auth/presentation/widgets/password_requirements_section.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreatePasswordFormCard extends StatelessWidget {
  const CreatePasswordFormCard({
    super.key,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.hasMinLength,
    required this.hasNumber,
    required this.hasSpecialChar,
  });

  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool hasMinLength;
  final bool hasNumber;
  final bool hasSpecialChar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: passwordController,
            labelText: S.of(context).newPassword,
            hintText: '••••••••',
            isPassword: true,
          ),
          SizedBox(height: 4.h),
          Text(
            S.of(context).passwordLengthHint,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 12.h),
          Divider(
            color: theme.dividerColor,
            thickness: 1,
          ),
          SizedBox(height: 12.h),
          CustomTextField(
            controller: confirmPasswordController,
            labelText: S.of(context).confirmNewPassword,
            hintText: '••••••••',
            isPassword: true,
          ),
          SizedBox(height: 16.h),
          PasswordRequirementsSection(
            hasMinLength: hasMinLength,
            hasNumber: hasNumber,
            hasSpecialChar: hasSpecialChar,
          ),
        ],
      ),
    );
  }
}
