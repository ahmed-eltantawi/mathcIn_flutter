import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:MatchIn/core/extensions/snack_bar_extensions.dart';
import 'package:MatchIn/core/services/speech_to_text_service.dart';
import 'package:MatchIn/features/chatbot/presentation/cubit/chatbot_voice_cubit.dart';
import 'package:MatchIn/generated/l10n.dart';

class ChatVoiceListener extends StatelessWidget {
  const ChatVoiceListener({
    super.key,
    required this.onTextRecognized,
    required this.child,
  });

  final ValueChanged<String> onTextRecognized;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatbotVoiceCubit, ChatbotVoiceState>(
      listener: (context, voiceState) {
        if (voiceState.recognizedText.isNotEmpty) {
          onTextRecognized(voiceState.recognizedText);
          context.read<ChatbotVoiceCubit>().clearRecognizedText();
        }

        if (voiceState.errorMessage != null) {
          _showVoiceError(context, voiceState);
          context.read<ChatbotVoiceCubit>().clearError();
        }
      },
      child: child,
    );
  }

  void _showVoiceError(BuildContext context, ChatbotVoiceState voiceState) {
    final s = S.of(context);
    final isPermanentlyDenied = voiceState.shouldOpenSettings;

    context.showErrorSnackBar(
      isPermanentlyDenied
          ? s.micPermissionPermanentlyDenied
          : _voiceErrorMessage(context, voiceState),
      action: isPermanentlyDenied
          ? SnackBarAction(
              label: s.settings,
              onPressed: () {
                context.read<ChatbotVoiceCubit>().openMicrophoneSettings();
              },
            )
          : null,
    );
  }

  String _voiceErrorMessage(
    BuildContext context,
    ChatbotVoiceState voiceState,
  ) {
    final s = S.of(context);

    return switch (voiceState.speechState) {
      SpeechState.permissionDenied => s.micPermissionDenied,
      SpeechState.unavailable => s.speechUnavailable,
      SpeechState.error => s.speechError,
      _ => s.speechError,
    };
  }
}
