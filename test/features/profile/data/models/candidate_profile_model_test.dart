import 'package:MatchIn/features/profile/data/models/candidate_profile_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CandidateProfileModel profile_exists=false', () {
    test('parses missing profile with profile_exists=false', () {
      final model = CandidateProfileModel.fromJson(const {
        'profile_exists': false,
        'user': {
          'id': 7,
          'name': 'New Candidate',
          'email': 'new@example.com',
          'role': 'candidate',
          'is_active': true,
        },
        'profile': null,
      });

      expect(model.profileExists, isFalse);
      expect(model.profile, isNull);
      expect(model.user.name, 'New Candidate');
      expect(model.skills, isEmpty);
      expect(model.education, isEmpty);
      expect(model.experience, isEmpty);
      expect(model.projects, isEmpty);
      expect(model.careerPreferences, isNull);
      expect(model.cvDocument, isNull);
    });

    test('defaults profile_exists to false when the key is absent', () {
      final model = CandidateProfileModel.fromJson(const {
        'user': {'id': 7, 'name': 'New Candidate'},
        'profile': null,
      });

      expect(model.profileExists, isFalse);
      expect(model.profile, isNull);
    });

    test(
      'round-trips profile_exists=false with null profile through cache',
      () {
        final model = CandidateProfileModel.fromJson(const {
          'profile_exists': false,
          'user': {'id': 7, 'name': 'New Candidate'},
          'profile': null,
        });

        final restored = CandidateProfileModel.fromJson(model.toJson());

        expect(restored.profileExists, isFalse);
        expect(restored.profile, isNull);
      },
    );

    test('parses existing profile with profile_exists=true', () {
      final model = CandidateProfileModel.fromJson(const {
        'profile_exists': true,
        'user': {'id': 1, 'name': 'Ahmed Mohamed'},
        'profile': {'id': 3, 'job_title': 'Junior Flutter Developer'},
      });

      expect(model.profileExists, isTrue);
      expect(model.profile, isNotNull);
      expect(model.profile!.jobTitle, 'Junior Flutter Developer');
    });
  });
}
