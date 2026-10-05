import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProjectsAppBar extends StatelessWidget {
  const ProjectsAppBar({
    super.key,
    required this.title,
    required this.onBackPressed,
  });

  final String title;
  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 56.h,
      child: Row(
        children: [
          IconButton(
            onPressed: onBackPressed,
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 21.r,
            ),
          ),
          SizedBox(width: 105.w),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
