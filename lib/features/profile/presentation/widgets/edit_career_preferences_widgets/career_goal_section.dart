import 'package:MatchIn/features/profile/presentation/widgets/edit_career_preferences_widgets/preference_section_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CareerGoalSection extends StatelessWidget {
  const CareerGoalSection({
    this.controller,
    this.onChanged,
    super.key,
  });

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return PreferenceSectionCard(
      title: locale.careerGoal,
      trailing: Text(
        locale.optional,
        style: theme.textTheme.labelMedium?.copyWith(
          color: colors.onSurfaceVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            onChanged: onChanged,
            minLines: 3,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: locale.careerGoalHint,
              filled: true,
              fillColor: colors.surface,
              contentPadding: EdgeInsets.all(14.r),
              border: _border(theme),
              enabledBorder: _border(theme),
              focusedBorder: _border(
                theme,
                color: colors.primary,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            locale.careerGoalHelper,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
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
