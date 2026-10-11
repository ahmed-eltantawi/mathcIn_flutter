import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SkillsAppBar extends StatelessWidget {
  const SkillsAppBar({
    super.key,
    required this.title,
    required this.onBackPressed,
  });

  final String title;
  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return SizedBox(
      height: 56.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: IconButton(
              onPressed: onBackPressed,
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 22.sp),
              color: colors.primary,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w700, color: colors.primary),
          ),
        ],
      ),
    );
  }
}
