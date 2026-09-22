import 'dart:io' as io;

import 'package:flutter_test/flutter_test.dart';
import 'package:rive/rive.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('inspect delete.riv asset file', () async {
    final bytes = io.File('assets/riv/delete.riv').readAsBytesSync();
    final file = await File.decode(bytes, riveFactory: Factory.flutter);
    expect(file, isNotNull);

    final artboard = file!.defaultArtboard();
    expect(artboard, isNotNull);

    if (artboard != null) {
      // ignore: avoid_print
      print('=== ARTBOARD NAME: "${artboard.name}" ===');
      // ignore: avoid_print
      print('=== STATE MACHINES count: ${artboard.stateMachineCount()} ===');
      for (int i = 0; i < artboard.stateMachineCount(); i++) {
        final sm = artboard.stateMachineAt(i);
        if (sm != null) {
          // ignore: avoid_print
          print('StateMachine: "${sm.name}"');
        }
      }
      // ignore: avoid_print
      print('=== ANIMATIONS count: ${artboard.animationCount()} ===');
      for (int i = 0; i < artboard.animationCount(); i++) {
        final anim = artboard.animationAt(i);
        // ignore: avoid_print
        print('Animation: "${anim.name}"');
      }
    }
  });
}
