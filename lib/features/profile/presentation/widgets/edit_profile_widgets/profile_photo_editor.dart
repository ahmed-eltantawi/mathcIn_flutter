import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePhotoEditor extends StatelessWidget {
  const ProfilePhotoEditor({super.key, this.avatarUrl, this.onChangePhoto});

  final String? avatarUrl;
  final VoidCallback? onChangePhoto;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final hasAvatar = avatarUrl != null && avatarUrl!.trim().isNotEmpty;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 92.r,
              height: 92.r,
              padding: EdgeInsets.all(3.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.dividerColor),
              ),
              child: CircleAvatar(
                backgroundColor: colors.surfaceContainerHighest,
                backgroundImage: hasAvatar ? NetworkImage(avatarUrl!) : null,
                child: hasAvatar
                    ? null
                    : Icon(
                        Icons.person_outline_rounded,
                        size: 44.r,
                        color: colors.onSurfaceVariant,
                      ),
              ),
            ),
            PositionedDirectional(
              end: -2.w,
              bottom: 5.h,
              child: Container(
                width: 32.r,
                height: 32.r,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.surface, width: 2),
                ),
                child: Icon(
                  Icons.photo_camera_outlined,
                  size: 17.r,
                  color: colors.onPrimary,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        TextButton(onPressed: onChangePhoto, child: Text(locale.changePhoto)),
      ],
    );
  }
}
