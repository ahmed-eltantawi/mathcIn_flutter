import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/generated/l10n.dart';

class SkillSearchField extends StatelessWidget {
  const SkillSearchField({
    required this.onAddPressed,
    this.controller,
    this.onChanged,
    super.key,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colors = theme.colorScheme;
    final S locale = S.of(context);

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52.h,
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: locale.addSkillHint,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 24.r,
                ),
                filled: true,
                fillColor: colors.surface,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 14.h,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: colors.outlineVariant,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: context.theme.dividerColor,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: colors.primary,
                    width: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        SizedBox(
          height: 52.h,
          child: FilledButton(
            onPressed: onAddPressed,
            style: FilledButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              padding: EdgeInsets.symmetric(
                horizontal: 20.w,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              locale.add,
              style: theme.textTheme.labelLarge?.copyWith(
                color: colors.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
