import 'dart:typed_data';

import 'package:MatchIn/core/errors/error_model.dart';
import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/networking/api_consumer.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_remote_data_source_impl.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_upload_input.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeCvApiConsumer implements ApiConsumer {
  dynamic postResponse;
  Object? postError;
  String? lastPostPath;
  Object? lastPostData;
  bool? lastPostIsFormData;

  @override
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
    void Function(int sentBytes, int totalBytes)? onSendProgress,
  }) async {
    if (postError != null) throw postError!;
    lastPostPath = path;
    lastPostData = data;
    lastPostIsFormData = isFormData;
    return postResponse;
  }

  @override
  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<({Uint8List bytes, String? fileName, String? mimeType})> downloadBytes(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    throw UnimplementedError();
  }
}

CvUploadInput testInput() => CvUploadInput(
  fileName: 'cv.pdf',
  extension: 'pdf',
  sizeBytes: 3,
  bytes: Uint8List.fromList([1, 2, 3]),
);

void main() {
  late FakeCvApiConsumer fakeApiConsumer;
  late ProfileRemoteDataSourceImpl remoteDataSource;

  setUp(() {
    fakeApiConsumer = FakeCvApiConsumer();
    remoteDataSource = ProfileRemoteDataSourceImpl(
      apiConsumer: fakeApiConsumer,
    );
  });

  group('ProfileRemoteDataSource.uploadCv', () {
    test('posts multipart cv field and parses the receipt', () async {
      fakeApiConsumer.postResponse = {
        'message': 'CV uploaded successfully.',
        'data': {'id': 2, 'version': 2, 'status': 'processing'},
      };

      final receipt = await remoteDataSource.uploadCv(testInput());

      expect(fakeApiConsumer.lastPostPath, 'cv/upload');
      expect(fakeApiConsumer.lastPostIsFormData, isTrue);
      final data = fakeApiConsumer.lastPostData as Map<String, dynamic>;
      expect(data.keys, ['cv']);
      final file = data['cv'] as MultipartFile;
      expect(file.filename, 'cv.pdf');
      expect(receipt, isNotNull);
      expect(receipt!.id, 2);
      expect(receipt.version, 2);
    });

    test('returns null for a malformed success payload', () async {
      fakeApiConsumer.postResponse = {
        'message': 'CV uploaded successfully.',
        'data': {'version': 2},
      };

      expect(await remoteDataSource.uploadCv(testInput()), isNull);
    });

    test('parses the current 201 JSON:API-style payload', () async {
      fakeApiConsumer.postResponse = {
        'status': 'success',
        'message': 'CV uploaded successfully.',
        'data': {
          'id': '10',
          'type': 'cvDocuments',
          'attributes': {
            'original_filename': 'cv.pdf',
            'mime_type': 'application/pdf',
            'file_size': 123456,
            'version': 2,
            'is_current': true,
            'status': 'uploaded',
          },
        },
      };

      final receipt = await remoteDataSource.uploadCv(testInput());

      expect(receipt, isNotNull);
      expect(receipt!.id, 10);
      expect(receipt.version, 2);
      expect(receipt.status, 'uploaded');
    });

    test('throws FormatException for a non-map envelope', () async {
      fakeApiConsumer.postResponse = 'ok';

      expect(
        () => remoteDataSource.uploadCv(testInput()),
        throwsA(isA<FormatException>()),
      );
    });

    test('propagates ServerException with field errors', () async {
      fakeApiConsumer.postError = ServerException(
        errorModel: const ErrorModel(
          statusCode: 422,
          errorMessage: 'The given data was invalid.',
          fieldErrors: {
            'cv': ['The cv field must be a file.'],
          },
        ),
      );

      try {
        await remoteDataSource.uploadCv(testInput());
        fail('Expected ServerException');
      } on ServerException catch (e) {
        expect(e.errorModel.fieldErrors['cv'], isNotEmpty);
      }
    });
  });

  group('Failure mapping reference', () {
    test('OfflineFailure has a default message', () {
      expect(const OfflineFailure().message, isNotEmpty);
    });
  });
}
