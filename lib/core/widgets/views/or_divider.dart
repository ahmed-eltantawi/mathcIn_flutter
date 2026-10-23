import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: context.colors.outline)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            S.of(context).or,
            style: context.theme.textTheme.bodyMedium
                ?.copyWith(color: context.colors.onSurfaceVariant),
          ),
        ),
        Expanded(child: Divider(color: context.colors.outline)),
      ],
    );
  }
}
