import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:MatchIn/core/services/speech_to_text_service.dart';
import 'package:MatchIn/generated/l10n.dart';

import 'voice_input_button.dart';

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
    final isDark = theme.brightness == Brightness.dark;
    final isListening = _speechState == SpeechState.listening;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.grey[800]!
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
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
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      s.listening,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey[850]
                    : theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.45,
                      ),
                borderRadius: BorderRadius.circular(26.r),
                border: Border.all(
                  color: isListening
                      ? Colors.red.withValues(alpha: 0.5)
                      : (isDark
                            ? Colors.grey[750]!
                            : theme.colorScheme.outline.withValues(alpha: 0.2)),
                  width: isListening ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Attachment / Action button
                  IconButton(
                    icon: Icon(
                      Icons.add_circle_outline_rounded,
                      size: 22.r,
                      color: theme.hintColor,
                    ),
                    onPressed: () {},
                    padding: EdgeInsets.all(6.r),
                    constraints: const BoxConstraints(),
                    tooltip: s.askAnything,
                  ),
                  SizedBox(width: 6.w),
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
                          color: theme.hintColor.withValues(alpha: 0.7),
                          fontSize: 15.sp,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10.h),
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
                    decoration: BoxDecoration(
                      color: (_canSend && !widget.isGenerating)
                          ? theme.primaryColor
                          : theme.disabledColor.withValues(alpha: 0.25),
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
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              Icons.arrow_upward_rounded,
                              size: 18.r,
                              color: (_canSend && !widget.isGenerating)
                                  ? Colors.white
                                  : theme.hintColor.withValues(alpha: 0.5),
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
