import 'package:MatchIn/features/profile/data/models/education_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EducationModel.tryParseMutation', () {
    test('returns the record for a complete mutation response', () {
      final model = EducationModel.tryParseMutation({
        'id': 7,
        'degree': 'Bachelor of Engineering',
        'institution': 'Ain Shams University',
        'field_of_study': 'Computer Engineering',
        'is_current': false,
        'start_date': '2018-09-01',
        'end_date': '2023-07-01',
        'grade': 'Excellent',
      });

      expect(model, isNotNull);
      expect(model!.id, 7);
      expect(model.institution, 'Ain Shams University');
      expect(model.fieldOfStudy, 'Computer Engineering');
    });

    test('returns null when id is missing', () {
      expect(
        EducationModel.tryParseMutation({
          'degree': 'Bachelor of Engineering',
          'institution': 'Ain Shams University',
        }),
        isNull,
      );
    });

    test('returns null when id is zero or negative', () {
      expect(
        EducationModel.tryParseMutation({'id': 0, 'institution': 'X'}),
        isNull,
      );
      expect(
        EducationModel.tryParseMutation({'id': -3, 'institution': 'X'}),
        isNull,
      );
    });

    test('returns null when institution is missing or blank', () {
      expect(
        EducationModel.tryParseMutation({'id': 4, 'grade': 'Excellent'}),
        isNull,
      );
      expect(
        EducationModel.tryParseMutation({'id': 4, 'institution': '   '}),
        isNull,
      );
    });

    test('returns null for a partial PATCH-style payload', () {
      expect(
        EducationModel.tryParseMutation({'id': 4, 'grade': 'Excellent'}),
        isNull,
      );
    });
  });

  group('EducationModel.fromJson', () {
    test('stays tolerant for GET list payloads', () {
      final model = EducationModel.fromJson(const {'id': 9});

      expect(model.id, 9);
      expect(model.degree, isEmpty);
      expect(model.institution, isEmpty);
      expect(model.isCurrent, isFalse);
    });
  });
}
