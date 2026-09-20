import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/services/speech_to_text_service.dart';
import 'package:MatchIn/features/chatbot/presentation/widgets/voice_input_button.dart';
import 'package:MatchIn/generated/l10n.dart';

class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.onSendMessage,
    required this.isGenerating,
  });

  final Function(String) onSendMessage;
  final bool isGenerating;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final TextEditingController _controller = TextEditingController();
  bool _canSend = false;
  SpeechState _speechState = SpeechState.idle;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final canSendNow = _controller.text.trim().isNotEmpty;
      if (canSendNow != _canSend) {
        setState(() {
          _canSend = canSendNow;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && !widget.isGenerating) {
      widget.onSendMessage(text);
      _controller.clear();
    }
  }

  void _onTextRecognized(String recognizedText) {
    if (recognizedText.isNotEmpty) {
      setState(() {
        _controller.text = recognizedText;
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isListening = _speechState == SpeechState.listening;
    final composerFillColor = colorScheme.surfaceContainerHighest.withValues(
      alpha: 0.5,
    );
    final statusColor = colorScheme.error;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isListening) ...[
              Padding(
                padding: EdgeInsets.only(bottom: 8.h, left: 12.w, right: 12.w),
                child: Row(
                  children: [
                    Container(
                      width: 8.r,
                      height: 8.r,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      s.listening,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: composerFillColor,
                borderRadius: BorderRadius.circular(28.r),
                border: Border.all(
                  color: isListening
                      ? statusColor.withValues(alpha: 0.55)
                      : colorScheme.outline.withValues(alpha: 0.16),
                  width: isListening ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Multiline Text Input
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 15.sp,
                      ),
                      decoration: InputDecoration(
                        hintText: s.askAnything,
                        hintStyle: TextStyle(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.68,
                          ),
                          fontSize: 15.sp,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        filled: true,
                        fillColor: composerFillColor,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 11.h),
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  // Speech-to-text Microphone button
                  VoiceInputButton(
                    onTextRecognized: _onTextRecognized,
                    onSpeechStateChanged: (state) {
                      setState(() {
                        _speechState = state;
                      });
                    },
                  ),
                  SizedBox(width: 6.w),
                  // Send Button inside the composer shell
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 38.r,
                    height: 38.r,
                    decoration: BoxDecoration(
                      color: (_canSend && !widget.isGenerating)
                          ? colorScheme.primary
                          : colorScheme.onSurface.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: (_canSend && !widget.isGenerating)
                          ? _handleSend
                          : null,
                      padding: EdgeInsets.all(8.r),
                      constraints: const BoxConstraints(),
                      tooltip: s.verify,
                      icon: widget.isGenerating
                          ? SizedBox(
                              width: 16.r,
                              height: 16.r,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.r,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : Icon(
                              Icons.arrow_upward_rounded,
                              size: 18.r,
                              color: (_canSend && !widget.isGenerating)
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurfaceVariant.withValues(
                                      alpha: 0.65,
                                    ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
