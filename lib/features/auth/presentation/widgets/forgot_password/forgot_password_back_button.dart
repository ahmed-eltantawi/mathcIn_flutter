import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:MatchIn/core/extensions/context_extensions.dart';

class ForgotPasswordBackButton extends StatelessWidget {
  const ForgotPasswordBackButton({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          context.l10n.backToLogin,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: context.colors.secondary,
          ),
        ),
      ),
    );
  }
}
