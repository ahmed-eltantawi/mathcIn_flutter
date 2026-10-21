import 'dart:typed_data';

import 'package:MatchIn/core/errors/error_model.dart';
import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/applications_remote_data_source_impl.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeApiConsumer implements ApiConsumer {
  dynamic getResponse;
  dynamic postResponse;
  dynamic patchResponse;
  Object? getError;
  String? lastPostPath;
  Object? lastPostData;

  @override
  Future delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  }) async {
    if (getError != null) throw getError!;
    return getResponse;
  }

  @override
  Future post(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
    void Function(int sentBytes, int totalBytes)? onSendProgress,
  }) async {
    if (getError != null) throw getError!;
    lastPostPath = path;
    lastPostData = data;
    return postResponse ?? getResponse;
  }

  @override
  Future put(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future patch(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  }) async {
    if (getError != null) throw getError!;
    return patchResponse ?? getResponse;
  }

  @override
  Future<({Uint8List bytes, String? fileName, String? mimeType})> downloadBytes(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  late FakeApiConsumer fakeApiConsumer;
  late ApplicationsRemoteDataSourceImpl remoteDataSource;

  setUp(() {
    fakeApiConsumer = FakeApiConsumer();
    remoteDataSource = ApplicationsRemoteDataSourceImpl(
      apiConsumer: fakeApiConsumer,
    );
  });

  group('ApplicationsRemoteDataSourceImpl Unit Tests', () {
    test('getApplications returns PaginatedApplicationsModel on 200', () async {
      fakeApiConsumer.getResponse = {
        'data': [
          {
            'id': '1',
            'type': 'applications',
            'attributes': {
              'status': 'applied',
              'cover_letter': 'Excited to apply.',
              'applied_at': '2026-09-01T10:00:00Z',
            },
          },
        ],
        'meta': {'current_page': 1, 'last_page': 1, 'total': 1},
      };

      final result = await remoteDataSource.getApplications();

      expect(result.applications.length, equals(1));
      expect(result.applications.first.id, equals('1'));
      expect(result.applications.first.status, equals('applied'));
    });

    test('applyToJob returns ApplicationModel on 201 Created', () async {
      fakeApiConsumer.postResponse = {
        'status': 'success',
        'data': {
          'id': '10',
          'type': 'applications',
          'attributes': {
            'status': 'applied',
            'cover_letter': 'Cover note text',
          },
        },
      };

      final result = await remoteDataSource.applyToJob(
        jobId: 7,
        coverLetter: 'Cover note text',
      );

      expect(result.id, equals('10'));
      expect(result.status, equals('applied'));
    });

    test('applyToJob sends the documented backend contract body', () async {
      fakeApiConsumer.postResponse = {
        'status': 'success',
        'data': {
          'id': '10',
          'type': 'applications',
          'attributes': {
            'status': 'applied',
            'cover_letter': 'Cover note text',
          },
        },
      };

      await remoteDataSource.applyToJob(
        jobId: 7,
        cvDocumentId: 3,
        coverLetter: 'Cover note text',
        notes: 'Extra notes',
      );

      expect(fakeApiConsumer.lastPostPath, equals('applications'));
      expect(
        fakeApiConsumer.lastPostData,
        equals({
          'job_post_id': 7,
          'cv_document_id': 3,
          'cover_letter': 'Cover note text',
          'notes': 'Extra notes',
        }),
      );
    });

    test(
      'applyToJob omits unset optional fields instead of inventing them',
      () async {
        fakeApiConsumer.postResponse = {
          'status': 'success',
          'data': {
            'id': '11',
            'type': 'applications',
            'attributes': {'status': 'applied'},
          },
        };

        await remoteDataSource.applyToJob(jobId: 7);

        expect(fakeApiConsumer.lastPostData, equals({'job_post_id': 7}));
      },
    );

    test('withdrawApplication returns updated ApplicationModel', () async {
      fakeApiConsumer.postResponse = {
        'status': 'success',
        'data': {
          'id': '10',
          'type': 'applications',
          'attributes': {'status': 'withdrawn'},
        },
      };

      final result = await remoteDataSource.withdrawApplication('10');

      expect(result.id, equals('10'));
      expect(result.status, equals('withdrawn'));
    });

    test('updateApplicationStatus throws ServerException on 422', () async {
      fakeApiConsumer.getError = ServerException(
        errorModel: const ErrorModel(
          statusCode: 422,
          errorMessage: 'Invalid status transition.',
        ),
      );

      expect(
        () => remoteDataSource.updateApplicationStatus(
          applicationId: '1',
          status: 'offer',
        ),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
