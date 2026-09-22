import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:MatchIn/core/services/speech_to_text_service.dart';

part 'chatbot_voice_state.dart';

class ChatbotVoiceCubit extends Cubit<ChatbotVoiceState> {
  ChatbotVoiceCubit({required this.speechToTextService})
    : super(const ChatbotVoiceState());

  final SpeechToTextService speechToTextService;

  Future<void> toggleListening({required String localeId}) async {
    if (state.isListening) {
      await stopListening();
      return;
    }

    await speechToTextService.startListening(
      localeId: localeId,
      onStateChanged: _setSpeechState,
      onResult: (text, isFinal) {
        emit(state.copyWith(recognizedText: text, clearErrorMessage: true));
      },
      onError: _setError,
    );
  }

  Future<void> stopListening() async {
    await speechToTextService.stopListening(onStateChanged: _setSpeechState);
  }

  Future<void> openMicrophoneSettings() async {
    await speechToTextService.openMicrophoneSettings();
  }

  void clearRecognizedText() {
    if (state.recognizedText.isEmpty) return;
    emit(state.copyWith(recognizedText: ''));
  }

  void clearError() {
    if (state.errorMessage == null) return;
    emit(state.copyWith(clearErrorMessage: true));
  }

  @override
  Future<void> close() async {
    await speechToTextService.cancelListening();
    return super.close();
  }

  void _setSpeechState(SpeechState speechState) {
    emit(
      state.copyWith(
        speechState: speechState,
        shouldOpenSettings:
            speechState == SpeechState.permissionPermanentlyDenied,
        clearErrorMessage: true,
      ),
    );
  }

  void _setError(String errorMessage) {
    emit(state.copyWith(errorMessage: errorMessage));
  }
}
