import 'package:MatchIn/core/errors/error_model.dart';
import 'package:MatchIn/features/jobsAndApplications/data/models/application_model.dart';
import 'package:MatchIn/features/jobsAndApplications/data/models/job_model.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/application_entity.dart';
import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('API-001 auth header', () {
    test('getAuthorizationValue emits a single space after Bearer', () {
      final value = ApiHeaderKey.getAuthorizationValue(
        accessToken: 'token123',
      );

      expect(value, 'Bearer token123');
      expect(value.contains('Bearer  '), isFalse);
    });
  });

  group('ApplicationStatus live values', () {
    test('under_review maps to underReview (not unknown)', () {
      expect(
        ApplicationStatus.fromString('under_review'),
        ApplicationStatus.underReview,
      );
    });

    test('underReview serializes back to under_review', () {
      expect(
        ApplicationStatus.underReview.toApiString(),
        'under_review',
      );
    });

    test('interview still maps correctly', () {
      expect(
        ApplicationStatus.fromString('interview'),
        ApplicationStatus.interview,
      );
    });
  });

  group('ApplicationModel live shapes', () {
    Map<String, dynamic> flatJson() => {
      'id': 2,
      'status': 'interview',
      'cover_letter': null,
      'notes': 'Technical interview scheduled for Tuesday 2 PM.',
      'applied_at': '2026-10-10T12:01:21.000Z',
      'created_at': null,
      'updated_at': null,
      'job': {
        'id': 2,
        'title': 'Full Stack React / Node Developer',
        'job_type': 'job',
        'work_mode': 'remote',
        'company': {'id': 2, 'name': 'PayMob', 'logo_url': null},
      },
    };

    test('parses flat list item shape', () {
      final model = ApplicationModel.fromJson(flatJson());

      expect(model.id, '2');
      expect(model.status, 'interview');
      expect(model.notes, contains('Tuesday'));
      expect(model.job?.title, 'Full Stack React / Node Developer');
      expect(
        model.toEntity().status,
        ApplicationStatus.interview,
      );
    });

    test('parses data-wrapped details shape', () {
      final model = ApplicationModel.fromJson({'data': flatJson()});

      expect(model.id, '2');
      expect(model.status, 'interview');
      expect(model.notes, contains('Tuesday'));
    });

    test('legacy attributes envelope still parses', () {
      final model = ApplicationModel.fromJson({
        'data': {
          'id': '9',
          'type': 'applications',
          'attributes': {'status': 'withdrawn'},
        },
      });

      expect(model.id, '9');
      expect(model.toEntity().status, ApplicationStatus.withdrawn);
    });
  });

  group('JobModel live extras', () {
    test('parses nested match score, salary and company', () {
      final model = JobModel.fromJson({
        'id': 1,
        'title': 'Backend Node.js Engineer',
        'work_mode': 'hybrid',
        'employment_type': 'full-time',
        'experience_level': 'mid-level',
        'city': 'Giza',
        'country': 'Egypt',
        'salary_min': 25000,
        'salary_max': 40000,
        'salary_currency': 'EGP',
        'is_saved': false,
        'company': {'id': 1, 'name': 'VOIS', 'logo_url': null},
        'required_skills': [],
        'preferred_skills': [],
        'match': {'match_score': 87.5},
      });

      expect(model.matchScore, 87.5);
      expect(model.salaryMin, 25000);
      expect(model.salaryCurrency, 'EGP');

      final entity = model.toEntity();
      expect(entity.matchPercentage, 88);
      expect(entity.salaryMin, 25000);
      expect(entity.currency, 'EGP');
    });
  });

  group('ErrorModel field errors', () {
    test('collects every field while keeping first message', () {
      final model = ErrorModel.fromJson({
        'message': 'The name must be at least 2 characters.',
        'errors': {
          'name': ['The name must be at least 2 characters.'],
          'email': ['The email must be a valid email address.'],
        },
      });

      expect(model.errorMessage, 'The name must be at least 2 characters.');
      expect(model.fieldErrors['email'], [
        'The email must be a valid email address.',
      ]);
      expect(model.fieldErrors.length, 2);
    });
  });
}
