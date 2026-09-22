import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:MatchIn/generated/l10n.dart';

class VoiceInputButton extends StatefulWidget {
  const VoiceInputButton({
    super.key,
    required this.isListening,
    required this.onPressed,
  });

  final bool isListening;
  final VoidCallback onPressed;

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant VoiceInputButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening == oldWidget.isListening) return;

    if (widget.isListening) {
      _animController.repeat(reverse: true);
    } else {
      _animController.stop();
      _animController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isListening = widget.isListening;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isListening ? _scaleAnimation.value : 1.0,
          child: Semantics(
            label: isListening
                ? S.of(context).listening
                : S.of(context).askAnything,
            button: true,
            child: IconButton(
              tooltip: isListening ? S.of(context).listening : null,
              onPressed: widget.onPressed,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: isListening
                      ? Colors.red.withValues(alpha: 0.15)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isListening ? Icons.mic : Icons.mic_none_rounded,
                  size: 22.r,
                  color: isListening ? Colors.red : theme.hintColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
