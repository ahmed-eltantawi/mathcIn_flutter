import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:MatchIn/features/auth/presentation/widgets/register/register_footer.dart';
import 'package:MatchIn/features/auth/presentation/widgets/register/register_form.dart';
import 'package:MatchIn/features/auth/presentation/widgets/register/register_header.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = S.of(context);

    return BlocProvider(
      create: (context) => GetIt.instance<AuthCubit>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.midnightBlue),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            locale.createAccount,
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppColors.midnightBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            children: [
              const RegisterHeader(),
              SizedBox(height: 32.h),
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    const RegisterForm(),
                    SizedBox(height: 16.h),
                    const RegisterFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
