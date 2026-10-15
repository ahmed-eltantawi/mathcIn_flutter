import 'package:MatchIn/features/profile/data/models/candidate_profile_model.dart';
import 'package:MatchIn/features/profile/data/models/cv_document_model.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_processing_status.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> userJson() => {
  'user': {
    'id': 1,
    'name': 'Ahmed',
    'email': 'ahmed@example.com',
    'role': 'candidate',
    'is_active': true,
  },
};

void main() {
  group('CvDocumentModel status mapping', () {
    CvProcessingStatus? statusOf(String? value) {
      return CvDocumentModel.fromJson({'id': 1, 'status': value}).status;
    }

    test('maps documented backend values', () {
      expect(statusOf('processing'), CvProcessingStatus.analyzing);
      expect(statusOf('completed'), CvProcessingStatus.analyzed);
      expect(statusOf('failed'), CvProcessingStatus.failed);
    });

    test('maps identical UI tokens', () {
      expect(statusOf('analyzing'), CvProcessingStatus.analyzing);
      expect(statusOf('analyzed'), CvProcessingStatus.analyzed);
    });

    test('maps unknown and legacy values to unknown', () {
      expect(statusOf('pending'), CvProcessingStatus.unknown);
      expect(statusOf('archived'), CvProcessingStatus.unknown);
      expect(statusOf(null), isNull);
    });

    test('maps uploaded to analyzing (awaiting analysis)', () {
      expect(statusOf('uploaded'), CvProcessingStatus.analyzing);
      expect(statusOf('Uploaded'), CvProcessingStatus.analyzing);
    });

    test('round-trips through canonical tokens', () {
      const model = CvDocumentModel(
        id: 1,
        status: CvProcessingStatus.analyzing,
      );
      final restored = CvDocumentModel.fromJson(model.toJson());
      expect(restored.status, CvProcessingStatus.analyzing);
    });
  });

  group('CvDocumentModel fields', () {
    test('parses confirmed schema fields and ignores storage paths', () {
      final model = CvDocumentModel.fromJson(const {
        'id': 3,
        'file_name': 'cv.pdf',
        'original_filename': 'My CV.pdf',
        'file_url': 'https://cdn.example.com/cv.pdf',
        'storage_path': 'cvs/3/cv.pdf',
        'version': 2,
        'is_current': true,
        'status': 'processing',
        'processed_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-01-02T00:00:00Z',
        'failure_reason': 'low quality scan',
      });

      expect(model.id, 3);
      expect(model.fileName, 'cv.pdf');
      expect(model.originalFilename, 'My CV.pdf');
      expect(model.fileUrl, 'https://cdn.example.com/cv.pdf');
      expect(model.version, 2);
      expect(model.isCurrent, isTrue);
      expect(model.status, CvProcessingStatus.analyzing);
      expect(model.processedAt, '2026-01-01T00:00:00Z');
      expect(model.updatedAt, '2026-01-02T00:00:00Z');
      expect(model.failureReason, 'low quality scan');
    });
  });

  group('Current CV selection', () {
    Map<String, dynamic> doc({
      required int id,
      bool? isCurrent,
      String status = 'completed',
    }) => {
      'id': id,
      'file_name': 'cv-$id.pdf',
      'status': status,
      'is_current': isCurrent,
    };

    test('selects the document flagged is_current', () {
      final profile = CandidateProfileModel.fromJson({
        ...userJson(),
        'profile_exists': true,
        'cvDocuments': [
          doc(id: 1, isCurrent: false),
          doc(id: 2, isCurrent: true),
        ],
      });

      expect(profile.cvDocument?.id, 2);
    });

    test('returns null when no document is flagged current', () {
      final profile = CandidateProfileModel.fromJson({
        ...userJson(),
        'profile_exists': true,
        'cvDocuments': [doc(id: 1), doc(id: 2)],
      });

      expect(profile.cvDocument, isNull);
    });

    test('returns null for an empty list', () {
      final profile = CandidateProfileModel.fromJson({
        ...userJson(),
        'profile_exists': true,
        'cvDocuments': const [],
      });

      expect(profile.cvDocument, isNull);
    });

    test('returns null when both list keys are missing', () {
      final profile = CandidateProfileModel.fromJson({
        ...userJson(),
        'profile_exists': true,
      });

      expect(profile.cvDocument, isNull);
    });

    test('falls back to the legacy singular payload', () {
      final profile = CandidateProfileModel.fromJson({
        ...userJson(),
        'profile_exists': true,
        'cv_document': const {
          'id': 7,
          'file_name': 'old.pdf',
          'status': 'analyzed',
        },
      });

      expect(profile.cvDocument?.id, 7);
      expect(profile.cvDocument?.status, CvProcessingStatus.analyzed);
    });

    test('ignores legacy fallback when the list key is explicitly null', () {
      final profile = CandidateProfileModel.fromJson({
        ...userJson(),
        'profile_exists': true,
        'cvDocuments': null,
        'cv_document': const {
          'id': 7,
          'file_name': 'old.pdf',
          'status': 'analyzed',
        },
      });

      expect(profile.cvDocument, isNull);
    });

    test('list takes precedence over a differing legacy payload', () {
      final profile = CandidateProfileModel.fromJson({
        ...userJson(),
        'profile_exists': true,
        'cvDocuments': [doc(id: 2, isCurrent: true)],
        'cv_document': const {
          'id': 7,
          'file_name': 'old.pdf',
          'status': 'analyzed',
        },
      });

      expect(profile.cvDocument?.id, 2);
    });

    test('skips malformed entries and selects the valid current one', () {
      final profile = CandidateProfileModel.fromJson({
        ...userJson(),
        'profile_exists': true,
        'cvDocuments': [
          'not-a-document',
          const {'id': 'abc', 'file_name': 'broken.pdf', 'is_current': true},
          doc(id: 2, isCurrent: true),
        ],
      });

      expect(profile.cvDocument?.id, 2);
    });

    test('cache round-trip preserves the selected document', () {
      final profile = CandidateProfileModel.fromJson({
        ...userJson(),
        'profile_exists': true,
        'profile': const {'id': 1, 'job_title': 'Developer'},
        'cv_document': const {
          'id': 2,
          'file_name': 'cv.pdf',
          'status': 'completed',
          'is_current': true,
        },
      });

      final restored = CandidateProfileModel.fromJson(profile.toJson());

      expect(restored.cvDocument?.id, 2);
      expect(restored.cvDocument?.status, CvProcessingStatus.analyzed);
    });
  });
}
