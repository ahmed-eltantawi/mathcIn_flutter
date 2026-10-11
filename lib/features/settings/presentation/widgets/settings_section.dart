import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: 4.w,
            bottom: 10.h,
          ),
          child: Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(
              color: colors.outline.withValues(alpha: 0.15),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: _withDividers(context, children),
          ),
        ),
      ],
    );
  }

  List<Widget> _withDividers(
    BuildContext context,
    List<Widget> widgets,
  ) {
    if (widgets.length <= 1) {
      return widgets;
    }

    final result = <Widget>[];

    for (var index = 0; index < widgets.length; index++) {
      result.add(widgets[index]);

      if (index != widgets.length - 1) {
        result.add(
          Padding(
            padding: EdgeInsetsDirectional.only(
              start: 68.w,
              end: 14.w,
            ),
            child: Divider(
              height: 1,
              color: context.colors.outline.withValues(alpha: 0.12),
            ),
          ),
        );
      }
    }

    return result;
  }
}
