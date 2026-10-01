import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/core/utils/app_text_styles.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';

class RegisterLoginLink extends StatelessWidget {
  const RegisterLoginLink({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onPressed,
        child: RichText(
          text: TextSpan(
            text: '${S.of(context).alreadyHaveAccount} ',
            style: AppTextStyles.body14Regular(
              isArabic: false,
              color: AppColors.textSecondary,
            ),
            children: [
              TextSpan(
                text: S.of(context).backToLogin,
                style: AppTextStyles.body14SemiBold(
                  isArabic: false,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
