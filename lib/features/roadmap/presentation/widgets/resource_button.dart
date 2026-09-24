import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/functions/show_image.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/utils/app_assets.dart';
import 'package:MatchIn/features/roadmap/data/models/skill_task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ResourceButton extends StatelessWidget {
  const ResourceButton({super.key, required this.resource});

  final TaskResource resource;

  String _getAssetPath() {
    switch (resource.type) {
      case TaskResourceType.youtube:
        return Assets.imagesVideo;
      case TaskResourceType.documentation:
        return Assets.imagesDoc;
      default:
        return Assets.imagesDocs;
    }
  }

  @override
  Widget build(BuildContext context) {
    final assetPath = _getAssetPath();
    final label = resource.title.isNotEmpty
        ? resource.title
        : resource.type.displayName;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.push(
            AppRoutes.kWebView,
            extra: {'url': resource.url, 'title': label},
          );
        },
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: context.theme.dividerColor, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20.w,
                height: 20.h,
                child: showImage(image: assetPath),
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: context.colors.onSurface,
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.arrow_outward_rounded,
                size: 14.r,
                color: context.colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
