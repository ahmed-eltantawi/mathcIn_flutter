part of 'chatbot_voice_cubit.dart';

class ChatbotVoiceState extends Equatable {
  const ChatbotVoiceState({
    this.speechState = SpeechState.idle,
    this.recognizedText = '',
    this.errorMessage,
    this.shouldOpenSettings = false,
  });

  final SpeechState speechState;
  final String recognizedText;
  final String? errorMessage;
  final bool shouldOpenSettings;

  bool get isListening => speechState == SpeechState.listening;

  ChatbotVoiceState copyWith({
    SpeechState? speechState,
    String? recognizedText,
    String? errorMessage,
    bool? shouldOpenSettings,
    bool clearErrorMessage = false,
  }) {
    return ChatbotVoiceState(
      speechState: speechState ?? this.speechState,
      recognizedText: recognizedText ?? this.recognizedText,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      shouldOpenSettings: shouldOpenSettings ?? this.shouldOpenSettings,
    );
  }

  @override
  List<Object?> get props => [
    speechState,
    recognizedText,
    errorMessage,
    shouldOpenSettings,
  ];
}
