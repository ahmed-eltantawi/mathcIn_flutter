import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';

class AiChatComposer extends StatefulWidget {
  const AiChatComposer({
    super.key,
    required this.onSendMessage,
    required this.isGenerating,
    this.enabled = true,
    this.controller,
    this.focusNode,
  });

  final ValueChanged<String> onSendMessage;
  final bool isGenerating;
  final bool enabled;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  @override
  State<AiChatComposer> createState() => _AiChatComposerState();
}

class _AiChatComposerState extends State<AiChatComposer> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _isLocalController = false;
  bool _isLocalFocusNode = false;
  bool _canSend = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _isLocalController = true;
    }

    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _isLocalFocusNode = true;
    }

    _canSend = _controller.text.trim().isNotEmpty;
    _controller.addListener(_handleTextChange);
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleTextChange() {
    final canSendNow = _controller.text.trim().isNotEmpty;
    if (canSendNow != _canSend) {
      setState(() {
        _canSend = canSendNow;
      });
    }
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus != _isFocused) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    _focusNode.removeListener(_handleFocusChange);
    if (_isLocalController) {
      _controller.dispose();
    }
    if (_isLocalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.isGenerating && widget.enabled) {
      widget.onSendMessage(text);
      _controller.clear();
      setState(() {
        _canSend = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEnabled = widget.enabled && !widget.isGenerating;

    return SafeArea(
      top: false,
      bottom: true,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 6.h,
          bottom: 10.h,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          constraints: BoxConstraints(
            minHeight: 52.h,
            maxHeight: 140.h,
          ),
          padding: EdgeInsetsDirectional.only(
            start: 16.w,
            end: 8.w,
            top: 4.h,
            bottom: 4.h,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? colors.surfaceContainerHighest.withValues(alpha: 0.45)
                : colors.surface,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(
              color: _isFocused
                  ? colors.primary.withValues(alpha: 0.6)
                  : colors.outline.withValues(alpha: isDark ? 0.25 : 0.2),
              width: 1.2.w,
            ),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(
                  alpha: isDark ? 0.25 : 0.05,
                ),
                blurRadius: 10.r,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      inputDecorationTheme: const InputDecorationTheme(
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        filled: false,
                        fillColor: Colors.transparent,
                      ),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: isEnabled,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      cursorColor: colors.primary,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface,
                        fontSize: 14.5.sp,
                        height: 1.35,
                      ),
                      decoration: InputDecoration(
                        hintText: context.l10n.askAnything,
                        hintStyle: context.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant.withValues(alpha: 0.55),
                          fontSize: 14.5.sp,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        filled: false,
                        fillColor: Colors.transparent,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              _ComposerSendButton(
                isGenerating: widget.isGenerating,
                canSend: _canSend && isEnabled,
                onSend: _handleSend,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComposerSendButton extends StatefulWidget {
  const _ComposerSendButton({
    required this.isGenerating,
    required this.canSend,
    required this.onSend,
  });

  final bool isGenerating;
  final bool canSend;
  final VoidCallback onSend;

  @override
  State<_ComposerSendButton> createState() => _ComposerSendButtonState();
}

class _ComposerSendButtonState extends State<_ComposerSendButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor;
    final Color iconColor;
    final double targetScale;

    if (widget.isGenerating) {
      bgColor = colors.primary.withValues(alpha: 0.15);
      iconColor = colors.primary;
      targetScale = 1.0;
    } else if (widget.canSend) {
      bgColor = colors.primary;
      iconColor = colors.onPrimary;
      targetScale = _isPressed ? 0.92 : 1.0;
    } else {
      bgColor = isDark
          ? colors.surfaceContainerHighest.withValues(alpha: 0.7)
          : colors.onSurface.withValues(alpha: 0.08);
      iconColor = colors.onSurfaceVariant.withValues(alpha: 0.35);
      targetScale = 0.95;
    }

    final tooltip = widget.isGenerating
        ? l10n.sendingMessage
        : (widget.canSend ? l10n.sendMessage : l10n.askAnything);

    return Semantics(
      button: true,
      enabled: widget.canSend && !widget.isGenerating,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: GestureDetector(
          onTapDown: widget.canSend && !widget.isGenerating
              ? (_) => setState(() => _isPressed = true)
              : null,
          onTapUp: widget.canSend && !widget.isGenerating
              ? (_) {
                  setState(() => _isPressed = false);
                  widget.onSend();
                }
              : null,
          onTapCancel: () {
            if (_isPressed) {
              setState(() => _isPressed = false);
            }
          },
          behavior: HitTestBehavior.opaque,
          child: AnimatedScale(
            scale: targetScale,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: widget.isGenerating
                    ? SizedBox(
                        width: 16.r,
                        height: 16.r,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2.w,
                          valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                        ),
                      )
                    : Icon(
                        Icons.arrow_upward_rounded,
                        size: 21.r,
                        color: iconColor,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
