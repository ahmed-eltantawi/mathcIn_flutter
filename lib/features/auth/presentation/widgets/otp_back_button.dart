import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';

class OtpBackButton extends StatelessWidget {
  const OtpBackButton({
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
          S.of(context).useDifferentEmail,
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppColors.secondary,
          ),
        ),
      ),
    );
  }
}
