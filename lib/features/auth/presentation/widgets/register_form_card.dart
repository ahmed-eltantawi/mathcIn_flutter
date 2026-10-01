import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/core/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterFormCard extends StatelessWidget {
  const RegisterFormCard({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          CustomTextField(
            controller: nameController,
            labelText: 'Full Name',
            hintText: 'John Doe',
          ),
          SizedBox(height: 16.h),
          CustomTextField(
            controller: emailController,
            labelText: 'Email Address',
            hintText: 'user@example.com',
          ),
          SizedBox(height: 16.h),
          CustomTextField(
            controller: passwordController,
            labelText: 'Password',
            hintText: '••••••••',
            isPassword: true,
          ),
        ],
      ),
    );
  }
}
