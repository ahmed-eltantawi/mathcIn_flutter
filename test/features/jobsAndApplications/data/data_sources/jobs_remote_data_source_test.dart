import 'package:MatchIn/core/errors/error_model.dart';
import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/features/jobsAndApplications/data/data_sources/jobs_remote_data_source_impl.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_filter_params.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeApiConsumer implements ApiConsumer {
  dynamic getResponse;
  Object? getError;

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
    if (getError != null) {
      throw getError!;
    }
    return getResponse;
  }

  @override
  Future post(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  }) async {
    if (getError != null) {
      throw getError!;
    }
    return getResponse;
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
}

void main() {
  late FakeApiConsumer fakeApiConsumer;
  late JobsRemoteDataSourceImpl remoteDataSource;

  setUp(() {
    fakeApiConsumer = FakeApiConsumer();
    remoteDataSource = JobsRemoteDataSourceImpl(apiConsumer: fakeApiConsumer);
  });

  group('JobsRemoteDataSourceImpl Tests', () {
    test('getJobs returns PaginatedJobsModel on 200 success', () async {
      fakeApiConsumer.getResponse = {
        'data': [
          {
            'id': 1,
            'title': 'Flutter Developer',
            'job_type': 'job',
            'work_mode': 'Remote',
            'employment_type': 'Full-time',
            'experience_level': 'Senior',
            'country': 'Egypt',
            'city': 'Cairo',
            'published_at': '2026-10-01T07:52:40.272Z',
            'is_saved': true,
            'company': {
              'id': 10,
              'name': 'MatchIn Tech',
            },
          }
        ],
        'meta': {
          'current_page': 1,
          'last_page': 5,
          'per_page': 15,
          'total': 75,
        }
      };

      final result = await remoteDataSource.getJobs(
        params: const JobFilterParams(page: 1, search: 'Flutter'),
      );

      expect(result.data.length, equals(1));
      expect(result.data.first.title, equals('Flutter Developer'));
      expect(result.meta?.currentPage, equals(1));
      expect(result.meta?.lastPage, equals(5));
      expect(result.data.first.isSaved, isTrue);
    });

    test('getJobs throws ServerException on 401 unauthenticated', () async {
      fakeApiConsumer.getError = ServerException(
        errorModel: ErrorModel(statusCode: 401, errorMessage: 'Unauthenticated.'),
      );

      expect(
        () => remoteDataSource.getJobs(),
        throwsA(isA<ServerException>()),
      );
    });

    test('getJobs throws ServerException on 403 forbidden', () async {
      fakeApiConsumer.getError = ServerException(
        errorModel: ErrorModel(
          statusCode: 403,
          errorMessage: 'Your account is inactive.',
        ),
      );

      expect(
        () => remoteDataSource.getJobs(),
        throwsA(isA<ServerException>()),
      );
    });

    test('getJobs throws ServerException on 422 validation error', () async {
      fakeApiConsumer.getError = ServerException(
        errorModel: ErrorModel(
          statusCode: 422,
          errorMessage: 'The given data was invalid.',
        ),
      );

      expect(
        () => remoteDataSource.getJobs(),
        throwsA(isA<ServerException>()),
      );
    });
  });
}
