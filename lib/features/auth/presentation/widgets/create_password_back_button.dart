import 'package:MatchIn/core/utils/app_text_styles.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';

class CreatePasswordBackButton extends StatelessWidget {
  const CreatePasswordBackButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          S.of(context).backToLogin,
          style: AppTextStyles.body14SemiBold(
            isArabic: false,
            color: theme.colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
