import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
