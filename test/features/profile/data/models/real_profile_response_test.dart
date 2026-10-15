import 'dart:convert';

import 'package:MatchIn/features/profile/data/models/candidate_profile_model.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_processing_status.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sanitized mirror of the real GET /candidate/profile payload:
/// relations nested inside the `profile` object under the confirmed
/// keys, ISO-8601 dates, nullable optionals, nested skill objects,
/// null arrays, three CV versions with exactly one current document
/// and no file URLs.
Map<String, dynamic> realProfilePayload() => const {
  'data': {
    'profile_exists': true,
    'user': {
      'id': 7,
      'name': 'Layla Hassan',
      'email': 'layla@example.com',
      'role': 'candidate',
      'is_active': true,
      'phone': null,
      'avatar': null,
    },
    'profile': {
      'id': 1,
      'date_of_birth': '2010-10-05T00:00:00.000000Z',
      'gender': 'female',
      'job_title': 'Backend Developer',
      'country': 'Egypt',
      'state': 'Cairo',
      'city': 'Cairo',
      'github_url': 'https://github.com/layla',
      'linkedin_url': 'https://linkedin.com/in/layla',
      'military_status': null,
      'professional_summary': 'Backend engineer.',
      'candidateSkills': [
        {
          'id': 3,
          'skill_id': 12,
          'source': null,
          'proficiency_level': 'advanced',
          'skill': {'id': 12, 'name': 'Dart'},
        },
        {
          'id': 'bogus',
          'skill': {'id': 13, 'name': 'Ghost'},
        },
      ],
      'educations': [
        {
          'id': 5,
          'degree': 'BSc Computer Science',
          'institution': 'Cairo University',
          'field_of_study': 'Computer Science',
          'start_date': '2020-09-01T00:00:00.000000Z',
          'end_date': '2024-06-01T00:00:00.000000Z',
          'grade': 'Excellent',
          'is_current': 0,
        },
        {'degree': 'Record without identity'},
      ],
      'experiences': [
        {
          'id': 8,
          'job_title': 'Backend Developer',
          'company_name': 'NileTech',
          'employment_type': 'full_time',
          'country': 'Egypt',
          'city': 'Cairo',
          'description': 'Payment APIs.',
          'technologies': ['Dart', 'PostgreSQL'],
          'start_date': '2024-01-01',
          'end_date': null,
          'is_current': true,
        },
      ],
      'projects': [
        {
          'id': 11,
          'name': 'Order Engine',
          'description': 'Queue engine.',
          'technologies': ['Dart'],
          'project_url': null,
          'github_url': 'https://github.com/layla/order-engine',
          'source': null,
          'start_date': null,
          'end_date': null,
        },
      ],
      'careerPreference': {
        'id': 2,
        'target_role': 'Senior Backend Engineer',
        'job_type': 'full_time',
        'work_mode': 'remote',
        'preferred_country': 'Egypt',
        'preferred_city': 'Cairo',
        'experience_level': 'senior',
        'career_goal': null,
        'open_to_relocation': 1,
        'target_roles': null,
        'preferred_industries': null,
      },
      'cvDocuments': [
        {
          'id': 1,
          'original_filename': 'cv-v1.pdf',
          'is_current': false,
          'version': 1,
          'status': 'completed',
        },
        {
          'id': 2,
          'original_filename': 'cv-v2.pdf',
          'is_current': false,
          'version': 2,
          'status': 'failed',
        },
        {
          'id': 5,
          'original_filename': 'cv.pdf',
          'mime_type': 'application/pdf',
          'file_size': 123456,
          'version': 3,
          'is_current': true,
          'status': 'uploaded',
          'updated_at': '2026-09-01T00:00:00.000000Z',
        },
      ],
    },
  },
};

/// Older cached-data shape: details-only profile plus legacy
/// top-level relation keys.
Map<String, dynamic> legacyCachePayload() => const {
  'profile_exists': true,
  'user': {'id': 7, 'name': 'Layla Hassan'},
  'profile': {'id': 1, 'job_title': 'Backend Developer'},
  'skills': [
    {
      'id': 3,
      'skill_id': 12,
      'skill': {'id': 12, 'name': 'Dart'},
    },
  ],
  'education': [
    {'id': 5, 'institution': 'Cairo University'},
  ],
  'cv_document': {'id': 5, 'original_filename': 'cv.pdf', 'status': 'uploaded'},
};

CandidateProfileModel parseRealProfile() {
  final data = realProfilePayload()['data'] as Map<String, dynamic>;
  return CandidateProfileModel.fromJson(data);
}

void main() {
  group('Real profile response parsing', () {
    test('parses profile flag, user, and details', () {
      final profile = parseRealProfile();

      expect(profile.profileExists, isTrue);
      expect(profile.user.name, 'Layla Hassan');
      expect(profile.profile, isNotNull);
      expect(profile.profile!.jobTitle, 'Backend Developer');
      // Domain keeps the raw backend value; display normalizes it.
      expect(profile.profile!.dateOfBirth, '2010-10-05T00:00:00.000000Z');
    });

    test('parses skills from nested skill objects', () {
      final profile = parseRealProfile();

      expect(profile.skills.map((skill) => skill.name), ['Dart']);
    });

    test('keeps valid education and skips identity-less records', () {
      final profile = parseRealProfile();

      expect(profile.education.length, 1);
      expect(profile.education.first.institution, 'Cairo University');
      expect(profile.education.first.isCurrent, isFalse);
    });

    test('parses experience with technologies and current flag', () {
      final profile = parseRealProfile();

      expect(profile.experience.length, 1);
      final experience = profile.experience.first;
      expect(experience.companyName, 'NileTech');
      expect(experience.technologies, ['Dart', 'PostgreSQL']);
      expect(experience.isCurrent, isTrue);
    });

    test('parses projects with nullable fields', () {
      final profile = parseRealProfile();

      expect(profile.projects.length, 1);
      expect(profile.projects.first.name, 'Order Engine');
      expect(profile.projects.first.projectUrl, isNull);
    });

    test('parses career preferences with int flag and null arrays', () {
      final profile = parseRealProfile();

      final career = profile.careerPreferences;
      expect(career, isNotNull);
      expect(career!.targetRole, 'Senior Backend Engineer');
      expect(career.openToRelocation, isTrue);
      expect(career.targetRoles, isEmpty);
      expect(career.preferredIndustries, isEmpty);
    });

    test('selects the current CV without requiring file_url', () {
      final profile = parseRealProfile();

      final document = profile.cvDocument;
      expect(document, isNotNull);
      expect(document!.id, 5);
      expect(document.isCurrent, isTrue);
      expect(document.originalFilename, 'cv.pdf');
      expect(document.fileUrl, isNull);
      expect(document.status, CvProcessingStatus.analyzing);
      expect(document.updatedAt, '2026-09-01T00:00:00.000000Z');
    });

    test('returns null CV when no document is current', () {
      final payload =
          jsonDecode(jsonEncode(realProfilePayload())) as Map<String, dynamic>;
      final profileMap =
          (payload['data'] as Map<String, dynamic>)['profile']
              as Map<String, dynamic>;
      final documents = (profileMap['cvDocuments'] as List)
          .map((item) => {...item as Map<String, dynamic>, 'is_current': false})
          .toList();
      profileMap['cvDocuments'] = documents;

      final data = payload['data'] as Map<String, dynamic>;
      expect(CandidateProfileModel.fromJson(data).cvDocument, isNull);
    });

    test('reads legacy top-level caches with details-only profile', () {
      final profile = CandidateProfileModel.fromJson(legacyCachePayload());

      expect(profile.profileExists, isTrue);
      expect(profile.profile!.jobTitle, 'Backend Developer');
      expect(profile.skills.map((skill) => skill.name), ['Dart']);
      expect(profile.education.length, 1);
      expect(profile.education.first.institution, 'Cairo University');
      expect(profile.cvDocument, isNotNull);
      expect(profile.cvDocument!.id, 5);
      expect(profile.cvDocument!.status, CvProcessingStatus.analyzing);
    });

    test('profile null yields no relations without fallback', () {
      final payload =
          jsonDecode(jsonEncode(realProfilePayload())) as Map<String, dynamic>;
      final data = payload['data'] as Map<String, dynamic>;
      data['profile'] = null;
      // Stale top-level relations must never be resurrected.
      data['candidateSkills'] = const [
        {
          'id': 3,
          'skill_id': 12,
          'skill': {'id': 12, 'name': 'Dart'},
        },
      ];

      final profile = CandidateProfileModel.fromJson(data);

      expect(profile.profileExists, isTrue);
      expect(profile.profile, isNull);
      expect(profile.skills, isEmpty);
      expect(profile.education, isEmpty);
      expect(profile.experience, isEmpty);
      expect(profile.projects, isEmpty);
      expect(profile.careerPreferences, isNull);
      expect(profile.cvDocument, isNull);
    });

    test('cache serialization round-trips all relations', () {
      final profile = parseRealProfile();
      final restored = CandidateProfileModel.fromJson(profile.toJson());

      expect(restored.profileExists, isTrue);
      expect(restored.profile!.jobTitle, 'Backend Developer');
      expect(restored.skills.map((skill) => skill.name), ['Dart']);
      expect(restored.education.length, 1);
      expect(restored.experience.length, 1);
      expect(restored.projects.length, 1);
      expect(restored.careerPreferences!.targetRole, 'Senior Backend Engineer');
      expect(restored.cvDocument!.id, 5);
      expect(restored.cvDocument!.isCurrent, isTrue);
    });
  });
}
