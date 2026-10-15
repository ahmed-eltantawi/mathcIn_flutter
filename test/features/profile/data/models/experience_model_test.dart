import 'package:MatchIn/features/profile/data/models/experience_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExperienceModel.tryParseMutation', () {
    test('returns the record for a complete mutation response', () {
      final model = ExperienceModel.tryParseMutation({
        'id': 5,
        'job_title': 'Senior Backend Developer',
        'company_name': 'PayMob',
        'employment_type': 'full_time',
        'is_current': true,
        'start_date': '2023-01-01',
        'description': 'Payments.',
      });

      expect(model, isNotNull);
      expect(model!.id, 5);
      expect(model.jobTitle, 'Senior Backend Developer');
      expect(model.companyName, 'PayMob');
    });

    test('returns null when id is missing or invalid', () {
      expect(
        ExperienceModel.tryParseMutation({
          'job_title': 'Senior Backend Developer',
          'company_name': 'PayMob',
        }),
        isNull,
      );
      expect(
        ExperienceModel.tryParseMutation({
          'id': 0,
          'job_title': 'Senior Backend Developer',
          'company_name': 'PayMob',
        }),
        isNull,
      );
    });

    test('returns null when company_name is missing or blank', () {
      expect(
        ExperienceModel.tryParseMutation({
          'id': 5,
          'job_title': 'Senior Backend Developer',
        }),
        isNull,
      );
      expect(
        ExperienceModel.tryParseMutation({
          'id': 5,
          'job_title': 'Senior Backend Developer',
          'company_name': '   ',
        }),
        isNull,
      );
    });

    test('returns null when job_title is missing or blank', () {
      expect(
        ExperienceModel.tryParseMutation({'id': 5, 'company_name': 'PayMob'}),
        isNull,
      );
      expect(
        ExperienceModel.tryParseMutation({
          'id': 5,
          'job_title': '',
          'company_name': 'PayMob',
        }),
        isNull,
      );
    });

    test('returns null for a partial payload with one identity field', () {
      expect(
        ExperienceModel.tryParseMutation({'id': 5, 'company_name': 'PayMob'}),
        isNull,
      );
      expect(
        ExperienceModel.tryParseMutation({
          'id': 5,
          'job_title': 'Senior Backend Developer',
        }),
        isNull,
      );
    });
  });

  group('ExperienceModel.fromJson', () {
    test('stays tolerant for GET list payloads', () {
      final model = ExperienceModel.fromJson(const {'id': 9});

      expect(model.id, 9);
      expect(model.jobTitle, isEmpty);
      expect(model.companyName, isEmpty);
      expect(model.isCurrent, isFalse);
      expect(model.technologies, isEmpty);
    });
  });
}
