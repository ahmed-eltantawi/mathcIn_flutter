import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';

class SavedTopBar extends StatelessWidget {
  const SavedTopBar({
    super.key,
    required this.title,
    this.onSearchTap,
  });

  final String title;
  final VoidCallback? onSearchTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.primary,
            ),
          ),
          InkWell(
            onTap: onSearchTap,
            borderRadius: BorderRadius.circular(9999),
            child: Container(
              width: 40.w,
              height: 40.w,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search,
                size: 20.sp,
                color: context.colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
