import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/extensions/snack_bar_extensions.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/core/utils/app_assets.dart';
import 'package:MatchIn/core/utils/validator.dart';
import 'package:MatchIn/core/widgets/custom_button.dart';
import 'package:MatchIn/core/widgets/custom_text_field.dart';
import 'package:MatchIn/features/auth/domain/use_cases/forgot_password_use_case.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({
    super.key,
    this.email,
  });

  final String? email;

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.email ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onSendCodePressed() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      final email = _emailController.text.trim();
      final result = await getIt<ForgotPasswordUseCase>().call(email: email);
      if (!mounted) return;
      setState(() => _isLoading = false);

      result.fold(
        (failure) {
          context.showErrorSnackBar(failure.message);
        },
        (_) {
          context.showSuccessSnackBar('Verification code sent to your email');
          context.push(
            AppRoutes.kOtpVerificationView,
            extra: email,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: context.colors.primary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.l10n.forgotPassword,
          style: context.textTheme.titleLarge?.copyWith(
            color: context.colors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 24.h,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const _ForgotPasswordLogo(imagePath: Assets.appIcon),
                SizedBox(height: 24.h),
                _ForgotPasswordCard(
                  formKey: _formKey,
                  emailController: _emailController,
                  isLoading: _isLoading,
                  onSendCodePressed: _onSendCodePressed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ForgotPasswordLogo extends StatelessWidget {
  const _ForgotPasswordLogo({required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      height: 100.h,
    );
  }
}

class _ForgotPasswordCard extends StatelessWidget {
  const _ForgotPasswordCard({
    required this.formKey,
    required this.emailController,
    required this.isLoading,
    required this.onSendCodePressed,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isLoading;
  final VoidCallback onSendCodePressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.colors.outline),
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter your email address to receive a verification code.',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              controller: emailController,
              labelText: context.l10n.email,
              hintText: context.l10n.emailHint,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              validator: Validator.validateEmail,
            ),
            SizedBox(height: 24.h),
            CustomButton(
              text: 'Send Verification Code',
              isLoading: isLoading,
              onPressed: onSendCodePressed,
            ),
          ],
        ),
      ),
    );
  }
}
