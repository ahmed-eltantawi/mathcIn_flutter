import 'package:MatchIn/features/profile/domain/entities/save_career_preferences_params.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SaveCareerPreferencesParams', () {
    test('has no changes by default', () {
      const params = SaveCareerPreferencesParams();

      expect(params.hasChanges, isFalse);
    });

    test('marks changed fields as set', () {
      final params = const SaveCareerPreferencesParams().copyWith(
        jobType: 'full_time',
      );

      expect(params.hasChanges, isTrue);
      expect(SaveCareerPreferencesParams.isSet(params.jobType), isTrue);
      expect(SaveCareerPreferencesParams.isSet(params.workMode), isFalse);
    });

    test('supports explicit null for cleared fields', () {
      final params = const SaveCareerPreferencesParams().copyWith(
        careerGoal: null,
      );

      expect(params.hasChanges, isTrue);
      expect(SaveCareerPreferencesParams.isSet(params.careerGoal), isTrue);
      expect(params.careerGoal, isNull);
    });

    test('never includes targetRoles without explicit opt-in', () {
      final params = const SaveCareerPreferencesParams().copyWith(
        targetRole: 'Backend Engineer',
      );

      expect(SaveCareerPreferencesParams.isSet(params.targetRoles), isFalse);
      expect(
        SaveCareerPreferencesParams.isSet(params.preferredIndustries),
        isFalse,
      );
    });
  });
}
