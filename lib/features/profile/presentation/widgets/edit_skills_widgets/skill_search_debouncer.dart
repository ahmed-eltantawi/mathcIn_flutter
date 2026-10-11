import 'dart:async';

class SkillSearchDebouncer {
  SkillSearchDebouncer({this.duration = const Duration(milliseconds: 400)});

  final Duration duration;

  Timer? _timer;

  void run(VoidCallback action) {
    _timer?.cancel();

    _timer = Timer(duration, action);
  }

  void cancel() {
    _timer?.cancel();
  }

  void dispose() {
    _timer?.cancel();
  }
}

typedef VoidCallback = void Function();
