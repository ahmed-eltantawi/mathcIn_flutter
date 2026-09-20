import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

enum SpeechState {
  idle,
  listening,
  processing,
  recognized,
  permissionDenied,
  unavailable,
  error,
}

class SpeechToTextService {
  SpeechToTextService({SpeechToText? speechToText})
      : _speechToText = speechToText ?? SpeechToText();

  final SpeechToText _speechToText;
  bool _isInitialized = false;

  bool get isListening => _speechToText.isListening;
  bool get isAvailable => _speechToText.isAvailable;

  Future<bool> initialize({
    Function(String status)? onStatus,
    Function(SpeechRecognitionError error)? onError,
  }) async {
    if (_isInitialized) return true;
    try {
      _isInitialized = await _speechToText.initialize(
        onStatus: onStatus,
        onError: onError,
      );
      return _isInitialized;
    } catch (_) {
      _isInitialized = false;
      return false;
    }
  }

  Future<void> startListening({
    required Function(String text, bool isFinal) onResult,
    required Function(SpeechState state) onStateChanged,
    Function(String errorMsg)? onError,
    String localeId = 'en_US',
  }) async {
    final available = await initialize();
    if (!available) {
      final hasMicPermission = await _speechToText.hasPermission;
      if (!hasMicPermission) {
        onStateChanged(SpeechState.permissionDenied);
        onError?.call('Microphone permission denied');
      } else {
        onStateChanged(SpeechState.unavailable);
        onError?.call('Speech recognition unavailable');
      }
      return;
    }

    onStateChanged(SpeechState.listening);

    try {
      await _speechToText.listen(
        onResult: (result) {
          if (result.recognizedWords.isNotEmpty) {
            onResult(result.recognizedWords, result.finalResult);
            if (result.finalResult) {
              onStateChanged(SpeechState.recognized);
            }
          }
        },
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          cancelOnError: true,
          partialResults: true,
        ),
      );
    } catch (e) {
      onStateChanged(SpeechState.error);
      onError?.call(e.toString());
    }
  }

  Future<void> stopListening({
    Function(SpeechState state)? onStateChanged,
  }) async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
      onStateChanged?.call(SpeechState.idle);
    }
  }

  Future<void> cancelListening({
    Function(SpeechState state)? onStateChanged,
  }) async {
    if (_speechToText.isListening) {
      await _speechToText.cancel();
      onStateChanged?.call(SpeechState.idle);
    }
  }
}
