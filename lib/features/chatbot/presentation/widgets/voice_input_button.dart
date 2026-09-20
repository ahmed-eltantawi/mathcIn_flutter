import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/core/services/speech_to_text_service.dart';
import 'package:MatchIn/generated/l10n.dart';

class VoiceInputButton extends StatefulWidget {
  const VoiceInputButton({
    super.key,
    required this.onTextRecognized,
    required this.onSpeechStateChanged,
  });

  final Function(String text) onTextRecognized;
  final Function(SpeechState state) onSpeechStateChanged;

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  SpeechState _speechState = SpeechState.idle;
  final SpeechToTextService _speechService = getIt<SpeechToTextService>();

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

  void _setSpeechState(SpeechState state) {
    if (!mounted) return;
    setState(() {
      _speechState = state;
    });
    widget.onSpeechStateChanged(state);

    if (state == SpeechState.listening) {
      _animController.repeat(reverse: true);
    } else {
      _animController.stop();
      _animController.reset();
    }
  }

  Future<void> _toggleListening() async {
    if (_speechState == SpeechState.listening) {
      await _speechService.stopListening(onStateChanged: _setSpeechState);
    } else {
      final locale = Localizations.localeOf(context).languageCode == 'ar'
          ? 'ar_SA'
          : 'en_US';

      await _speechService.startListening(
        localeId: locale,
        onStateChanged: _setSpeechState,
        onResult: (text, isFinal) {
          widget.onTextRecognized(text);
        },
        onError: (errorMsg) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMsg),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isListening = _speechState == SpeechState.listening;

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
              onPressed: _toggleListening,
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
