import 'package:MatchIn/features/profile/presentation/widgets/edit_experience_widgets/experience_technologies_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExperienceTechnologiesParser.parse', () {
    test('converts comma-separated input into a list', () {
      expect(ExperienceTechnologiesParser.parse('Flutter, Dart, Firebase'), [
        'Flutter',
        'Dart',
        'Firebase',
      ]);
    });

    test('trims whitespace and removes empty entries', () {
      expect(ExperienceTechnologiesParser.parse('  Node.js,,  Express , '), [
        'Node.js',
        'Express',
      ]);
    });

    test('preserves input order', () {
      expect(ExperienceTechnologiesParser.parse('Zebra, Apple, Mango'), [
        'Zebra',
        'Apple',
        'Mango',
      ]);
    });

    test('returns an empty list for blank input', () {
      expect(ExperienceTechnologiesParser.parse(''), isEmpty);
      expect(ExperienceTechnologiesParser.parse('   '), isEmpty);
    });

    test('keeps a single value as a one-item list', () {
      expect(ExperienceTechnologiesParser.parse('Kotlin'), ['Kotlin']);
    });
  });

  group('ExperienceTechnologiesParser.join', () {
    test('joins technologies for the Edit-mode field', () {
      expect(
        ExperienceTechnologiesParser.join(['Flutter', 'Dart', 'Firebase']),
        'Flutter, Dart, Firebase',
      );
    });

    test('returns an empty string for an empty list', () {
      expect(ExperienceTechnologiesParser.join(const []), isEmpty);
    });
  });
}
