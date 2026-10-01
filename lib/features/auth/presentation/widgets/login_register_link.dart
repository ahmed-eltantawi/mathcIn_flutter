import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/core/utils/app_text_styles.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';

class LoginRegisterLink extends StatelessWidget {
  const LoginRegisterLink({
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
            text: '${S.of(context).newHere} ',
            style: AppTextStyles.body14Regular(
              isArabic: false,
              color: AppColors.textSecondary,
            ),
            children: [
              TextSpan(
                text: S.of(context).createAccount,
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
