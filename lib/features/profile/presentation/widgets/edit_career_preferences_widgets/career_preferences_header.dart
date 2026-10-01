import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CareerPreferencesHeader extends StatelessWidget {
  const CareerPreferencesHeader({
    required this.onBackPressed,
    required this.onMenuPressed,
    super.key,
  });

  final VoidCallback onBackPressed;
  final VoidCallback onMenuPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = S.of(context);

    return SizedBox(
      height: 56.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: IconButton(
              onPressed: onBackPressed,
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 21.r,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 52.w),
            child: Text(
              locale.careerPreferences,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: IconButton(
              onPressed: onMenuPressed,
              icon: Icon(
                Icons.more_vert_rounded,
                size: 23.r,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
