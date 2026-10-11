import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ThemeSelectionBottomSheet extends StatelessWidget {
  const ThemeSelectionBottomSheet({
    super.key,
    required this.currentThemeMode,
    required this.onThemeSelected,
  });

  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeSelected;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.selectTheme,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),
          _ThemeOption(
            icon: Icons.light_mode_outlined,
            title: l10n.light,
            isSelected: currentThemeMode == ThemeMode.light,
            onTap: () {
              Navigator.of(context).pop();
              onThemeSelected(ThemeMode.light);
            },
          ),
          SizedBox(height: 10.h),
          _ThemeOption(
            icon: Icons.dark_mode_outlined,
            title: l10n.dark,
            isSelected: currentThemeMode == ThemeMode.dark,
            onTap: () {
              Navigator.of(context).pop();
              onThemeSelected(ThemeMode.dark);
            },
          ),
          SizedBox(height: 10.h),
          _ThemeOption(
            icon: Icons.settings_brightness_outlined,
            title: l10n.system,
            isSelected: currentThemeMode == ThemeMode.system,
            onTap: () {
              Navigator.of(context).pop();
              onThemeSelected(ThemeMode.system);
            },
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = context.theme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.08)
              : colors.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? colors.primary : colors.outline.withValues(alpha: 0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? colors.primary : colors.onSurface.withValues(alpha: 0.7),
              size: 22.sp,
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected ? colors.primary : colors.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: colors.primary,
                size: 22.sp,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: colors.onSurface.withValues(alpha: 0.3),
                size: 22.sp,
              ),
          ],
        ),
      ),
    );
  }
}
