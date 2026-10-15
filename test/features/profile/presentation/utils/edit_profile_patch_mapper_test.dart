import 'package:MatchIn/features/profile/domain/entities/candidate_profile_details_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_profile_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/profile_user_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_candidate_profile_params.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/edit_profile_patch_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

CandidateProfileEntity makeBaseline() => const CandidateProfileEntity(
  profileExists: true,
  user: ProfileUserEntity(
    id: 1,
    name: 'Ahmed Mohamed',
    email: 'ahmed@example.com',
    role: 'candidate',
    isActive: true,
    phone: '01012345678',
  ),
  profile: CandidateProfileDetailsEntity(
    id: 3,
    dateOfBirth: '2000-01-01',
    gender: 'male',
    jobTitle: 'Junior Flutter Developer',
    country: 'Egypt',
    state: 'Cairo',
    city: 'Cairo',
    githubUrl: 'https://github.com/ahmed',
    linkedinUrl: 'https://linkedin.com/in/ahmed',
    militaryStatus: 'exempted',
    professionalSummary: 'Looking for Flutter opportunities.',
  ),
);

UpdateCandidateProfileParams mapCurrent(
  CandidateProfileEntity baseline, {
  String? jobTitle,
  String? githubUrl,
  String? linkedinUrl,
  String? gender,
  String? country,
  String? state,
  String? city,
  String? dateOfBirth,
  String? militaryStatus,
}) {
  final details = baseline.profile;
  return EditProfilePatchMapper.fromDiff(
    baseline: baseline,
    dateOfBirth: dateOfBirth ?? details?.dateOfBirth ?? '',
    gender: gender ?? details?.gender,
    jobTitle: jobTitle ?? details?.jobTitle ?? '',
    country: country ?? details?.country,
    state: state ?? details?.state,
    city: city ?? details?.city,
    githubUrl: githubUrl ?? details?.githubUrl ?? '',
    linkedinUrl: linkedinUrl ?? details?.linkedinUrl ?? '',
    militaryStatus: militaryStatus ?? details?.militaryStatus,
  );
}

void main() {
  group('EditProfilePatchMapper', () {
    test('updates a single field and omits the rest', () {
      final params = mapCurrent(
        makeBaseline(),
        jobTitle: 'Senior Flutter Developer',
      );

      expect(params.hasChanges, isTrue);
      expect(UpdateCandidateProfileParams.isSet(params.jobTitle), isTrue);
      expect(params.jobTitle as String?, 'Senior Flutter Developer');
      expect(UpdateCandidateProfileParams.isSet(params.githubUrl), isFalse);
      expect(UpdateCandidateProfileParams.isSet(params.linkedinUrl), isFalse);
      expect(UpdateCandidateProfileParams.isSet(params.gender), isFalse);
      expect(UpdateCandidateProfileParams.isSet(params.country), isFalse);
    });

    test('sends explicit null when a nullable field is cleared', () {
      final params = mapCurrent(makeBaseline(), githubUrl: '   ');

      expect(params.hasChanges, isTrue);
      expect(UpdateCandidateProfileParams.isSet(params.githubUrl), isTrue);
      expect(params.githubUrl, isNull);
    });

    test('omits all unchanged fields', () {
      final params = mapCurrent(makeBaseline());

      expect(params.hasChanges, isFalse);
    });

    test('always omits professional_summary', () {
      final params = mapCurrent(
        makeBaseline(),
        jobTitle: 'Senior Flutter Developer',
      );

      expect(
        UpdateCandidateProfileParams.isSet(params.professionalSummary),
        isFalse,
      );
    });

    test('treats null baseline profile as empty for diffing', () {
      const baseline = CandidateProfileEntity(
        profileExists: false,
        user: ProfileUserEntity(
          id: 1,
          name: 'New User',
          email: 'new@example.com',
          role: 'candidate',
          isActive: true,
        ),
      );

      final params = EditProfilePatchMapper.fromDiff(
        baseline: baseline,
        dateOfBirth: '',
        gender: null,
        jobTitle: '',
        country: null,
        state: null,
        city: null,
        githubUrl: '',
        linkedinUrl: '',
        militaryStatus: null,
      );

      expect(params.hasChanges, isFalse);
    });

    test('builds a create request from user input on null baseline', () {
      const baseline = CandidateProfileEntity(
        profileExists: false,
        user: ProfileUserEntity(
          id: 1,
          name: 'New User',
          email: 'new@example.com',
          role: 'candidate',
          isActive: true,
        ),
      );

      final params = EditProfilePatchMapper.fromDiff(
        baseline: baseline,
        dateOfBirth: '2000-01-01',
        gender: 'male',
        jobTitle: 'Junior Flutter Developer',
        country: null,
        state: null,
        city: null,
        githubUrl: '',
        linkedinUrl: '',
        militaryStatus: null,
      );

      expect(params.hasChanges, isTrue);
      expect(params.dateOfBirth as String?, '2000-01-01');
      expect(params.gender as String?, 'male');
      expect(params.jobTitle as String?, 'Junior Flutter Developer');
      expect(UpdateCandidateProfileParams.isSet(params.country), isFalse);
      expect(UpdateCandidateProfileParams.isSet(params.githubUrl), isFalse);
    });

    test('sends only changed location fields through PATCH', () {
      final params = mapCurrent(
        makeBaseline(),
        country: 'Germany',
        state: 'Bavaria',
        city: 'Munich',
      );

      expect(params.hasChanges, isTrue);
      expect(params.country as String?, 'Germany');
      expect(params.state as String?, 'Bavaria');
      expect(params.city as String?, 'Munich');
      expect(UpdateCandidateProfileParams.isSet(params.jobTitle), isFalse);
      expect(UpdateCandidateProfileParams.isSet(params.gender), isFalse);
      expect(
        UpdateCandidateProfileParams.isSet(params.militaryStatus),
        isFalse,
      );
    });

    test('sends a changed military status through PATCH', () {
      final params = mapCurrent(makeBaseline(), militaryStatus: 'completed');

      expect(params.hasChanges, isTrue);
      expect(params.militaryStatus as String?, 'completed');
      expect(UpdateCandidateProfileParams.isSet(params.country), isFalse);
    });
  });
}
