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
    final theme = Theme.of(context);

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
              color: theme.colorScheme.onSurface.withValues(
                alpha: 0.6,
              ),
            ),
          ),
        ),

        Card(
          margin: EdgeInsets.zero,
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
              start: 70.w,
              end: 14.w,
            ),
            child: const Divider(height: 1),
          ),
        );
      }
    }

    return result;
  }
}
