import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CvProfileHeader extends StatelessWidget {
  const CvProfileHeader({required this.hasCv, this.onEdit, super.key});

  final bool hasCv;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final locale = S.of(context);

    return Row(
      children: [
        Icon(Icons.description_outlined, size: 24.r, color: colors.primary),

        SizedBox(width: 10.w),

        Expanded(
          child: Text(
            locale.cv,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
        ),

        if (hasCv)
          IconButton(
            onPressed: onEdit,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.all(6.r),
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.edit_outlined,
              size: 20.r,
              color: colors.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
