import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileOverviewAvatar extends StatelessWidget {
  const ProfileOverviewAvatar({this.imageUrl, super.key});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final hasAvatar = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return Container(
      width: 56.r,
      height: 56.r,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: hasAvatar
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) {
                return Icon(
                  Icons.person_rounded,
                  size: 32.r,
                  color: colors.onSurfaceVariant,
                );
              },
            )
          : Icon(
              Icons.person_rounded,
              size: 32.r,
              color: colors.onSurfaceVariant,
            ),
    );
  }
}
