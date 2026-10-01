import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/preference_choice_chip.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/preference_section_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TargetRoleSection extends StatelessWidget {
  const TargetRoleSection({
    required this.targetRole,
    required this.suggestedRoles,
    required this.selectedSuggestedRole,
    required this.onRoleChanged,
    required this.onClear,
    required this.onSuggestedRolePressed,
    super.key,
  });

  final String targetRole;
  final List<String> suggestedRoles;
  final String? selectedSuggestedRole;
  final ValueChanged<String> onRoleChanged;
  final VoidCallback onClear;
  final ValueChanged<String> onSuggestedRolePressed;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return PreferenceSectionCard(
      title: locale.targetRole,
      trailing: Text(
        locale.required,
        style: theme.textTheme.labelMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            initialValue: targetRole,
            onChanged: onRoleChanged,
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 21.r,
              ),
              suffixIcon: IconButton(
                onPressed: onClear,
                icon: Icon(
                  Icons.cancel_outlined,
                  size: 20.r,
                ),
              ),
              filled: true,
              fillColor: colors.surfaceContainerHighest,
              enabledBorder: _border(theme),
              border: _border(theme),
              focusedBorder: _border(
                theme,
                color: colors.primary,
              ),
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            locale.suggestedRoles.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 9.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: suggestedRoles
                .map(
                  (role) => PreferenceChoiceChip(
                    label: role,
                    isSelected:
                        role == selectedSuggestedRole,
                    onPressed: () =>
                        onSuggestedRolePressed(role),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _border(
    ThemeData theme, {
    Color? color,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: BorderSide(
        color: color ?? theme.dividerColor,
        width: 1,
      ),
    );
  }
}
