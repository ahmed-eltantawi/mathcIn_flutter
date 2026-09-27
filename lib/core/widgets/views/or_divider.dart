import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.border)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            S.of(context).or,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.border)),
      ],
    );
  }
}
