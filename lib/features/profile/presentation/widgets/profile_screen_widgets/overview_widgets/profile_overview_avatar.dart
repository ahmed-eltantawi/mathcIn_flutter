import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileOverviewAvatar extends StatelessWidget {
  const ProfileOverviewAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      width: 76.r,
      height: 76.r,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: Icon(
        Icons.person_rounded,
        size: 32.r,
        color: colors.onSurfaceVariant,
      ),
    );
  }
}
