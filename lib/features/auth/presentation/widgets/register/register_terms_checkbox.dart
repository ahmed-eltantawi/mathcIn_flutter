import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterTermsCheckbox extends StatelessWidget {
  final ValueNotifier<bool> isTermsAccepted;

  const RegisterTermsCheckbox({super.key, required this.isTermsAccepted});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: isTermsAccepted,
          builder: (context, value, child) {
            return SizedBox(
              width: 24.w,
              height: 24.h,
              child: Checkbox(
                value: value,
                activeColor: AppColors.midnightBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
                onChanged: (newValue) =>
                    isTermsAccepted.value = newValue ?? false,
              ),
            );
          },
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            locale.termsAndConditions,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
