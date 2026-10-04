import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OngoingProjectCheckbox extends StatelessWidget {
  const OngoingProjectCheckbox({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = S.of(context);

    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8.r),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24.r,
            height: 24.r,
            child: Checkbox(value: value, onChanged: onChanged),
          ),
          SizedBox(width: 10.w),
          Text(locale.ongoingProject, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
