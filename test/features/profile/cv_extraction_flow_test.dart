import 'dart:typed_data';

import 'package:MatchIn/core/errors/error_model.dart';
import 'package:MatchIn/core/errors/exceptions.dart';
import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/core/networking/network_info.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source_impl.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:MatchIn/features/profile/data/models/cv_extraction_status_model.dart';
import 'package:MatchIn/features/profile/data/models/cv_file_download.dart';
import 'package:MatchIn/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_extraction_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_extraction_status_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_processing_status.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_verify_params.dart';
import 'package:MatchIn/features/profile/domain/repositories/profile_repository.dart';
import 'package:MatchIn/features/profile/domain/use_cases/download_cv_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_cv_history_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_cv_status_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_local_cv_file_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_pending_cv_upload_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/retry_cv_extraction_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/retry_pending_cv_upload_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/upload_cv_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/verify_extraction_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/cv_cubit/cv_upload_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/cv_cubit/cv_upload_state.dart';
import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeCvFlowRemote extends Fake implements ProfileRemoteDataSource {
  Object? statusError;
  Map<String, dynamic>? statusResponse;
  int statusCalls = 0;

  Object? retryError;
  Map<String, dynamic>? retryResponse;

  Object? verifyError;
  int verifyCalls = 0;
  Map<String, dynamic>? lastVerifyBody;

  Object? downloadError;
  ({Uint8List bytes, String? fileName, String? mimeType})? downloadResponse;

  @override
  Future<CvExtractionStatusModel> getCvStatus(int cvDocumentId) async {
    statusCalls++;
    if (statusError != null) throw statusError!;
    return CvExtractionStatusModel.fromJson(statusResponse!);
  }

  @override
  Future<CvExtractionStatusModel> retryCvExtraction(int cvDocumentId) async {
    if (retryError != null) throw retryError!;
    return CvExtractionStatusModel.fromJson(retryResponse!);
  }

  @override
  Future<void> verifyExtraction(CvVerifyParams params) async {
    verifyCalls++;
    lastVerifyBody = params.toJson();
    if (verifyError != null) throw verifyError!;
  }

  @override
  Future<CvFileDownload> downloadCv({int? cvDocumentId}) async {
    if (downloadError != null) throw downloadError!;
    final response = downloadResponse!;
    return CvFileDownload(
      bytes: response.bytes,
      fileName: response.fileName,
      mimeType: response.mimeType,
    );
  }
}

class FakeCvFlowNetwork extends Fake implements NetworkInfo {
  FakeCvFlowNetwork({this.connected = true});

  bool connected;

  @override
  Future<bool> get isConnected async => connected;
}

class FakeCvFlowRepository extends Fake implements ProfileRepository {
  Either<Failure, CvExtractionStatusEntity>? statusResult;
  Either<Failure, Unit>? verifyResult;
  int verifyCalls = 0;
  CvVerifyParams? lastVerifyParams;
  final List<Either<Failure, CvExtractionStatusEntity>> statusQueue = [];

  @override
  Future<Either<Failure, CvExtractionStatusEntity>> getCvStatus(
    int cvDocumentId,
  ) async {
    if (statusQueue.isNotEmpty) return statusQueue.removeAt(0);
    return statusResult!;
  }

  @override
  Future<Either<Failure, Unit>> verifyExtraction(CvVerifyParams params) async {
    verifyCalls++;
    lastVerifyParams = params;
    return verifyResult!;
  }
}

CvUploadCubit buildCubit(FakeCvFlowRepository repo) => CvUploadCubit(
  uploadCvUseCase: UploadCvUseCase(repository: repo),
  getPendingCvUploadUseCase: GetPendingCvUploadUseCase(repository: repo),
  retryPendingCvUploadUseCase: RetryPendingCvUploadUseCase(repository: repo),
  getLocalCvFileUseCase: GetLocalCvFileUseCase(repository: repo),
  getCvStatusUseCase: GetCvStatusUseCase(repository: repo),
  getCvHistoryUseCase: GetCvHistoryUseCase(repository: repo),
  retryCvExtractionUseCase: RetryCvExtractionUseCase(repository: repo),
  verifyExtractionUseCase: VerifyExtractionUseCase(repository: repo),
  downloadCvUseCase: DownloadCvUseCase(repository: repo),
  pollInterval: const Duration(milliseconds: 10),
);

Map<String, dynamic> statusPayload({
  required String status,
  Map<String, dynamic>? parsedData,
  String? error,
}) => {
  'data': {
    'id': 2,
    'candidate_id': 1,
    'file_name': 'cv.pdf',
    'status': status,
    'parsed_data': parsedData,
    'error_message': error,
    'created_at': '2026-10-11T08:29:29.682Z',
  },
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CvExtractionStatusModel', () {
    test('parses the documented status envelope', () {
      final model = CvExtractionStatusModel.fromJson(
        statusPayload(
          status: 'processing',
          parsedData: {
            'skills': [
              'Dart',
              {'name': 'Flutter'},
            ],
          },
        ),
      );

      expect(model.documentId, 2);
      expect(model.status, CvProcessingStatus.analyzing);
      expect(model.fileName, 'cv.pdf');
      expect(model.isTerminal, isFalse);
      expect(
        model.extraction!.skills.map((s) => s.label),
        containsAll(['Dart', 'Flutter']),
      );
    });

    test('maps unknown status tokens without crashing', () {
      final model = CvExtractionStatusModel.fromJson(
        statusPayload(status: 'quarantined'),
      );

      expect(model.status, CvProcessingStatus.unknown);
      expect(model.isTerminal, isFalse);
    });

    test('parses failed extraction with the server reason', () {
      final model = CvExtractionStatusModel.fromJson(
        statusPayload(status: 'failed', error: 'Unreadable PDF'),
      );

      expect(model.status, CvProcessingStatus.failed);
      expect(model.isTerminal, isTrue);
      expect(model.errorMessage, 'Unreadable PDF');
    });
  });

  group('CvVerifyParams', () {
    test('serializes the documented verify schema', () {
      const params = CvVerifyParams(
        extractionId: 9,
        skills: [CvExtractedItem(name: 'Dart')],
        experiences: [CvExtractedItem(title: 'Engineer', subtitle: 'NileTech')],
      );
      final json = params.toJson();

      expect(json['action'], 'confirm');
      expect(json['verified_skills'], [
        {'name': 'Dart'},
      ]);
      expect(json['verified_experiences'], [
        {'title': 'Engineer', 'company_name': 'NileTech'},
      ]);
      expect(json['verified_educations'], isEmpty);
    });
  });

  group('ProfileRepository CV extraction', () {
    late FakeCvFlowRemote remote;
    late FakeCvFlowNetwork network;
    late ProfileRepositoryImpl repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final helper = SharedPreferencesHelper(preferences: prefs);
      remote = FakeCvFlowRemote();
      network = FakeCvFlowNetwork();
      repository = ProfileRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: ProfileLocalDataSourceImpl(
          sharedPreferencesHelper: helper,
        ),
        networkInfo: network,
      );
    });

    test('offline status check reports OfflineFailure', () async {
      network.connected = false;

      final result = await repository.getCvStatus(2);

      expect(result.isLeft(), isTrue);
      expect((result as Left).value, isA<OfflineFailure>());
      expect(remote.statusCalls, 0);
    });

    test('binary download is never JSON-decoded', () async {
      remote.downloadResponse = (
        bytes: Uint8List.fromList([37, 80, 68, 70]),
        fileName: 'cv.pdf',
        mimeType: 'application/pdf',
      );

      final result = await repository.downloadCv(cvDocumentId: 2);

      expect(result.isRight(), isTrue);
      final file = (result as Right).value;
      expect(file.bytes.length, 4);
      expect(file.fileName, 'cv.pdf');
      expect(file.isPdf, isTrue);
    });

    test(
      'empty download reports ServerFailure, offline reports offline',
      () async {
        remote.downloadResponse = (
          bytes: Uint8List(0),
          fileName: null,
          mimeType: null,
        );
        final empty = await repository.downloadCv();

        expect(empty.isLeft(), isTrue);

        network.connected = false;
        final offline = await repository.downloadCv();

        expect((offline as Left).value, isA<OfflineFailure>());
      },
    );

    test('verify maps 422 field errors without losing them', () async {
      remote.verifyError = ServerException(
        errorModel: const ErrorModel(
          statusCode: 422,
          errorMessage: 'The given data was invalid.',
          fieldErrors: {
            'verified_skills': ['At least one skill is required.'],
          },
        ),
      );

      final result = await repository.verifyExtraction(
        const CvVerifyParams(extractionId: 9),
      );

      expect(result.isLeft(), isTrue);
      final failure = (result as Left).value;
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).fieldErrors['verified_skills'], [
        'At least one skill is required.',
      ]);
    });
  });

  group('CvUploadCubit extraction polling', () {
    test('terminal completed state carries reviewable extraction', () async {
      final repo = FakeCvFlowRepository()
        ..statusResult = Right(
          CvExtractionStatusModel.fromJson(
            statusPayload(
              status: 'completed',
              parsedData: {
                'skills': ['Dart'],
              },
            ),
          ),
        );
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await cubit.watchExtraction(2);

      final state = cubit.state;
      expect(state, isA<CvExtractionCompleted>());
      final completed = state as CvExtractionCompleted;
      expect(completed.docId, 2);
      expect(completed.extraction!.skills.map((s) => s.label), ['Dart']);
    });

    test('polling continues on analyzing, then completes', () async {
      final repo = FakeCvFlowRepository()
        ..statusQueue.addAll([
          Right(
            CvExtractionStatusModel.fromJson(
              statusPayload(status: 'processing'),
            ),
          ),
          Right(
            CvExtractionStatusModel.fromJson(
              statusPayload(status: 'completed'),
            ),
          ),
        ]);
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await cubit.watchExtraction(2);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(cubit.state, isA<CvExtractionCompleted>());
    });

    test('failed extraction surfaces retryable failure with reason', () async {
      final repo = FakeCvFlowRepository()
        ..statusResult = Right(
          CvExtractionStatusModel.fromJson(
            statusPayload(status: 'failed', error: 'Unreadable PDF'),
          ),
        );
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      await cubit.watchExtraction(2);

      final state = cubit.state as CvExtractionFailed;
      expect(state.message, 'Unreadable PDF');
      expect(state.canRetry, isTrue);
    });

    test('verify submits the real extraction id exactly once', () async {
      final repo = FakeCvFlowRepository()..verifyResult = const Right(unit);
      final cubit = buildCubit(repo);
      addTearDown(cubit.close);

      const params = CvVerifyParams(
        extractionId: 9,
        skills: [CvExtractedItem(name: 'Dart')],
      );
      // A concurrent duplicate submit while verifying collapses into the
      // in-flight request instead of firing twice.
      final first = cubit.verifyExtraction(params);
      final second = cubit.verifyExtraction(params);
      await Future.wait([first, second]);

      expect(repo.verifyCalls, 1);
      expect(repo.lastVerifyParams?.extractionId, 9);
      expect(cubit.state, isA<CvVerified>());
    });

    test(
      'verify failure preserves the error without closing the form',
      () async {
        final repo = FakeCvFlowRepository()
          ..verifyResult = const Left(
            ServerFailure(message: 'The given data was invalid.'),
          );
        final cubit = buildCubit(repo);
        addTearDown(cubit.close);

        await cubit.verifyExtraction(const CvVerifyParams(extractionId: 9));

        final state = cubit.state as CvVerifyFailure;
        expect(state.message, 'The given data was invalid.');
      },
    );
  });
}
