import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';

/// Standard theme-aware circular icon button used in headers and top action bars.
/// Automatically adapts its container background, border, icon color, and badge to the active theme.
class AppCircleIconButton extends StatelessWidget {
  const AppCircleIconButton({
    super.key,
    required this.onTap,
    this.icon,
    this.svgAsset,
    this.hasBadge = false,
    this.badgeColor,
    this.size,
    this.iconSize,
    this.iconColor,
    this.tooltip,
  }) : assert(
          icon != null || svgAsset != null,
          'Either icon or svgAsset must be provided',
        );

  final VoidCallback onTap;
  final IconData? icon;
  final String? svgAsset;
  final bool hasBadge;
  final Color? badgeColor;
  final double? size;
  final double? iconSize;
  final Color? iconColor;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveSize = size ?? 36.r;
    final effectiveIconSize = iconSize ?? 18.sp;
    final effectiveIconColor = iconColor ?? colors.onSurface;

    Widget buttonContent = Stack(
      alignment: Alignment.center,
      children: [
        if (icon != null)
          Icon(
            icon,
            size: effectiveIconSize,
            color: effectiveIconColor,
          )
        else if (svgAsset != null)
          SvgPicture.asset(
            svgAsset!,
            width: effectiveIconSize,
            height: effectiveIconSize,
            colorFilter: ColorFilter.mode(
              effectiveIconColor,
              BlendMode.srcIn,
            ),
          ),
        if (hasBadge)
          PositionedDirectional(
            top: 6.r,
            end: 6.r,
            child: Container(
              width: 8.r,
              height: 8.r,
              decoration: BoxDecoration(
                color: badgeColor ?? colors.secondary,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );

    if (tooltip != null) {
      buttonContent = Tooltip(
        message: tooltip!,
        child: buttonContent,
      );
    }

    return Container(
      width: effectiveSize,
      height: effectiveSize,
      decoration: BoxDecoration(
        color: colors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: buttonContent,
        ),
      ),
    );
  }
}
