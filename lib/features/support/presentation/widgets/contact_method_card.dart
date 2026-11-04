import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContactMethodCard extends StatelessWidget {
  const ContactMethodCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.iconColor,
    super.key,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      elevation: 0,
      color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
        side: BorderSide(color: colors.outline.withValues(alpha: 0.14)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? colors.primary, size: 22.r),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.labelMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      value,
                      textDirection: TextDirection.ltr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.arrow_outward_rounded,
                color: colors.onSurfaceVariant,
                size: 18.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
