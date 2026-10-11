import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.centerTitle = true,
    this.showBackButton = true,
    this.onBack,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.elevation = 0,
    this.height,
    this.titleStyle,
    this.systemOverlayStyle,
  });

  final String? title;
  final Widget? titleWidget;

  final bool centerTitle;
  final bool showBackButton;

  final VoidCallback? onBack;

  final Widget? leading;
  final List<Widget>? actions;

  final Color? backgroundColor;
  final double elevation;
  final double? height;

  final TextStyle? titleStyle;
  final SystemUiOverlayStyle? systemOverlayStyle;

  @override
  Size get preferredSize {
    return Size.fromHeight(height ?? 56.h);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectiveLeading = _buildLeading(context, colorScheme);

    final effectiveTitle = _buildTitle(context);

    return AppBar(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      foregroundColor: colorScheme.onSurface,

      elevation: elevation,
      scrolledUnderElevation: 0,

      centerTitle: centerTitle,

      leading: effectiveLeading,
      automaticallyImplyLeading: false,

      title: effectiveTitle,
      actions: actions,

      systemOverlayStyle: systemOverlayStyle ?? _getSystemOverlayStyle(theme),

      toolbarHeight: height ?? 56.h,
    );
  }

  Widget? _buildLeading(BuildContext context, ColorScheme colorScheme) {
    if (leading != null) {
      return leading;
    }

    if (!showBackButton) {
      return null;
    }

    return SizedBox(
      width: 40.w,
      height: 40.h,
      child: IconButton(
        onPressed:
            onBack ??
            () {
              if (context.canPop()) {
                context.pop();
              } else {
                Navigator.maybePop(context);
              }
            },
        icon: Transform.flip(
          flipX: Directionality.of(context) == TextDirection.rtl,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18.sp,
            color: colorScheme.onSurface,
          ),
        ),
        splashRadius: 20.r,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget? _buildTitle(BuildContext context) {
    if (titleWidget != null) {
      return titleWidget;
    }

    if (title == null) {
      return null;
    }

    return Text(
      title!,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: titleStyle ?? Theme.of(context).textTheme.titleMedium,
    );
  }

  SystemUiOverlayStyle _getSystemOverlayStyle(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
  }
}
