import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LanguageSelectionBottomSheet extends StatelessWidget {
  const LanguageSelectionBottomSheet({
    super.key,
    required this.currentLanguageCode,
    required this.onLanguageSelected,
  });

  final String currentLanguageCode;
  final ValueChanged<String> onLanguageSelected;

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
            l10n.selectLanguage,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 16.h),
          _LanguageOption(
            title: l10n.english,
            subtitle: 'English',
            isSelected: currentLanguageCode == 'en',
            onTap: () {
              Navigator.of(context).pop();
              onLanguageSelected('en');
            },
          ),
          SizedBox(height: 10.h),
          _LanguageOption(
            title: l10n.arabic,
            subtitle: 'العربية',
            isSelected: currentLanguageCode == 'ar',
            onTap: () {
              Navigator.of(context).pop();
              onLanguageSelected('ar');
            },
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? colors.primary : colors.onSurface,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
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
