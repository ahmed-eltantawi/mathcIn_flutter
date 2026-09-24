import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchResultsHeader extends StatelessWidget {
  const SearchResultsHeader({
    super.key,
    required this.opportunitiesCount,
    this.onSortTap,
  });

  final int opportunitiesCount;
  final VoidCallback? onSortTap;

  @override
  Widget build(BuildContext context) {
    final style = context.textTheme.bodyMedium?.copyWith(
      color: context.colors.onSurface.withValues(alpha: 0.6),
    );

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Text(
            '$opportunitiesCount ${context.l10n.opportunities}',
            style: style,
          ),

          const Spacer(),

          InkWell(
            onTap: onSortTap,
            borderRadius: BorderRadius.circular(8.r),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.l10n.mostRelevant, style: style),
                  SizedBox(width: 2.w),
                  const Icon(Icons.keyboard_arrow_down_rounded),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
