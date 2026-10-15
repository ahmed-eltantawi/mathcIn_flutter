import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/networking/connectivity_cubit.dart';
import 'package:MatchIn/core/networking/connectivity_state.dart';
import 'package:MatchIn/generated/l10n.dart';

/// YouTube-style compact, non-blocking connectivity indicator.
/// Positioned immediately above the bottom navigation bar.
class OfflineIndicatorWidget extends StatelessWidget {
  const OfflineIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final colors = context.colors;
    final textTheme = context.textTheme;

    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (context, state) {
        final isVisible = state.shouldShowBanner;

        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          child: !isVisible
              ? const SizedBox.shrink()
              : _buildBanner(context, state, s, colors, textTheme),
        );
      },
    );
  }

  Widget _buildBanner(
    BuildContext context,
    ConnectivityState state,
    S s,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
    final Color backgroundColor;
    final Color foregroundColor;
    final IconData icon;
    final String message;

    switch (state.status) {
      case ConnectivityStatus.offline:
        backgroundColor = colors.surfaceContainerHighest;
        foregroundColor = colors.error;
        icon = Icons.wifi_off_rounded;
        message = s.offlineStatusShowingSaved;
        break;
      case ConnectivityStatus.poorConnection:
        backgroundColor = colors.surfaceContainerHighest;
        foregroundColor = colors.tertiary;
        icon = Icons.network_check_rounded;
        message = s.connectionSlowRetrying;
        break;
      case ConnectivityStatus.reconnected:
        backgroundColor = colors.primaryContainer;
        foregroundColor = colors.onPrimaryContainer;
        icon = Icons.wifi_rounded;
        message = s.backOnline;
        break;
      case ConnectivityStatus.online:
        return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16.r,
              color: foregroundColor,
            ),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                message,
                style: textTheme.bodySmall?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
