import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddProjectButton extends StatelessWidget {
  const AddProjectButton({required this.onPressed, super.key});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final locale = S.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      height: 46.h,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: context.theme.dividerColor, width: 1),
        ),
        icon: Icon(Icons.add_rounded, size: 20.r),
        label: Text(
          locale.addNewProject,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
