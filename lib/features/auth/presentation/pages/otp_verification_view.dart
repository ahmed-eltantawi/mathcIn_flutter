import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/core/widgets/custom_app_bar.dart';
import 'package:MatchIn/core/widgets/custom_snack_bar.dart';
import 'package:MatchIn/features/auth/presentation/cubit/otp_cubit.dart';
import 'package:MatchIn/features/auth/presentation/widgets/otp/otp_back_button.dart';
import 'package:MatchIn/features/auth/presentation/widgets/otp/otp_header.dart';
import 'package:MatchIn/features/auth/presentation/widgets/otp/otp_input_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class OtpVerificationView extends StatefulWidget {
  const OtpVerificationView({
    super.key,
    this.email = 'user@example.com',
    this.isPasswordReset = false,
  });

  final String email;
  final bool isPasswordReset;

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  String? _resetToken;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OtpCubit>().startTimer();
      }
    });
  }

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.kLoginView);
    }
  }

  Future<void> _onSuccessAnimationDone(BuildContext context) async {
    if (widget.isPasswordReset) {
      final token = _resetToken ?? context.read<OtpCubit>().resetToken ?? '';
      if (context.mounted) {
        context.go(
          AppRoutes.kCreateNewPasswordView,
          extra: {
            'email': widget.email,
            'resetToken': token,
          },
        );
      }
    } else {
      await getIt<SharedPreferencesService>().setLoggedIn();
      if (context.mounted) {
        context.go(AppRoutes.kHomeView);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OtpCubit, OtpState>(
      listener: (context, state) {
        if (state is OtpVerificationSuccess) {
          _resetToken = state.resetToken;
        } else if (state is OtpResendSuccess) {
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
                  email: widget.email,
                  isPasswordReset: widget.isPasswordReset,
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
