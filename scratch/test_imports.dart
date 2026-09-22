import 'package:rive/rive.dart';

void main() {
  // Verify key package exports from package:rive/rive.dart
  final fileType = File;
  final widgetType = RiveWidget;
  final artboardType = Artboard;

  // ignore: avoid_print
  print('Successfully loaded types: $fileType, $widgetType, $artboardType');
}
