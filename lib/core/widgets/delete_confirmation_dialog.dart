import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/utils/app_assets.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rive/rive.dart';

/// Displays the interactive Rive confirmation dialog.
Future<void> showDeleteConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required Future<bool> Function() onConfirm,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => DeleteConfirmationDialog(
      title: title,
      message: message,
      onConfirm: onConfirm,
    ),
  );
}

class DeleteConfirmationDialog extends StatefulWidget {
  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
  });

  final String title;
  final String message;
  final Future<bool> Function() onConfirm;

  @override
  State<DeleteConfirmationDialog> createState() =>
      _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState extends State<DeleteConfirmationDialog> {
  RiveWidgetController? _controller;
  TriggerInput? _clickTrigger;
  BooleanInput? _hoverYBool;
  BooleanInput? _hoverNBool;
  bool _isLoading = false;
  bool _fileLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
  }

  Future<void> _loadRiveFile() async {
    final file = await File.asset(
      Assets.deleteRiv,
      riveFactory: Factory.flutter,
    );
    if (file != null && mounted) {
      final controller = RiveWidgetController(
        file,
        artboardSelector: const ArtboardNamed('Delete v2'),
        stateMachineSelector: const StateMachineNamed('State Machine 1'),
      );
      // ignore: deprecated_member_use
      _clickTrigger = controller.stateMachine.trigger('click') ??
          // ignore: deprecated_member_use
          controller.stateMachine.trigger('yes no click');
      // ignore: deprecated_member_use
      _hoverYBool = controller.stateMachine.boolean('hover y');
      // ignore: deprecated_member_use
      _hoverNBool = controller.stateMachine.boolean('hover n');

      setState(() {
        _controller = controller;
        _fileLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _handleConfirm() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    _clickTrigger?.fire();
    if (_hoverYBool != null) {
      _hoverYBool!.value = true;
    }

    try {
      final success = await widget.onConfirm();
      if (mounted && success) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isDark = context.theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: Container(
        width: 340.w,
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 24.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24.r,
              offset: Offset(0, 10.h),
            ),
          ],
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
            width: 1.w,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Header with Title & Close (X) Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 4.h, right: 8.w),
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: context.colors.onSurface,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context, rootNavigator: true).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    size: 22.r,
                    color: context.colors.onSurfaceVariant,
                  ),
                  tooltip: s.cancel,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            SizedBox(height: 10.h),

            // Warning message
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.message,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  color: context.colors.onSurfaceVariant.withValues(alpha: 0.85),
                  height: 1.4,
                ),
              ),
            ),

            SizedBox(height: 20.h),

            // Interactive Rive Delete Button Area
            MouseRegion(
              onEnter: (_) {
                if (_hoverYBool != null) _hoverYBool!.value = true;
              },
              onExit: (_) {
                if (_hoverYBool != null) _hoverYBool!.value = false;
                if (_hoverNBool != null) _hoverNBool!.value = false;
              },
              child: GestureDetector(
                onTap: _handleConfirm,
                child: Container(
                  height: 130.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark
                        ? context.colors.surfaceContainerHighest
                            .withValues(alpha: 0.2)
                        : const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : Colors.black.withValues(alpha: 0.04),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_fileLoaded && _controller != null)
                        RiveWidget(
                          controller: _controller!,
                          fit: Fit.contain,
                        )
                      else
                        const Center(
                          child: CircularProgressIndicator.adaptive(),
                        ),
                      if (_isLoading)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator.adaptive(),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
