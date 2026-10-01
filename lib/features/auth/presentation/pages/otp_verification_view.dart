import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/core/widgets/custom_app_bar.dart';
import 'package:MatchIn/core/widgets/custom_snack_bar.dart';
import 'package:MatchIn/features/auth/presentation/cubit/otp_cubit.dart';
import 'package:MatchIn/features/auth/presentation/cubit/otp_state.dart';
import 'package:MatchIn/features/auth/presentation/widgets/otp/otp_back_button.dart';
import 'package:MatchIn/features/auth/presentation/widgets/otp/otp_header.dart';
import 'package:MatchIn/features/auth/presentation/widgets/otp/otp_input_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class OtpVerificationView extends StatelessWidget {
  const OtpVerificationView({
    super.key,
    this.email = 'user@example.com',
    this.isPasswordReset =
        false, // 1. ضفنا الفلاج ده عشان الشاشة تعرف هي في أي فلو
  });

  final String email;
  final bool isPasswordReset; // 2. تعريف الفلاج

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.kLoginView);
    }
  }

  Future<void> _onSuccessAnimationDone(BuildContext context) async {
    // 3. التوجيه الذكي بناءً على الفلاج
    if (isPasswordReset) {
      // لو ده فلو تغيير الباسورد -> نروح لشاشة الباسورد الجديد ونباصي التوكن
      final cubit = context.read<OtpCubit>();
      if (context.mounted) {
        context.go(
          AppRoutes.kCreateNewPasswordView,
          extra: {
            'email': email,
            'resetToken': cubit.resetToken ?? '', // التوكن اللي راجع من الـ API
          },
        );
      }
    } else {
      // لو تسجيل حساب جديد -> نعمل لوجين ونروح الهوم
      await getIt<SharedPreferencesService>().setLoggedIn();
      if (context.mounted) {
        context.go(AppRoutes.kHomeView);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<OtpCubit>().startTimer();
      }
    });

    return BlocListener<OtpCubit, OtpState>(
      listener: (context, state) {
        if (state is OtpResendSuccess) {
          CustomSnackBar.showSuccess(
            context,
            message: S.of(context).resendCode,
          );
        } else if (state is OtpResendError) {
          CustomSnackBar.showError(context, message: state.message);
        } else if (state is OtpVerificationError) {
          CustomSnackBar.showError(context, message: state.message);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: S.of(context).enterVerificationCode,
          onBack: () => _handleBack(context),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const OtpHeader(),
                SizedBox(height: 24.h),
                OtpInputCard(
                  email: email,
                  isPasswordReset: isPasswordReset,
                  onSuccessAnimationDone: () =>
                      _onSuccessAnimationDone(context),
                ),
                SizedBox(height: 24.h),
                OtpBackButton(onPressed: () => _handleBack(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
