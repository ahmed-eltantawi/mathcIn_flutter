import 'dart:typed_data';

import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_local_file.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_pending_upload.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_upload_input.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_upload_receipt.dart';
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
import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeCvRepository extends Fake implements ProfileRepository {
  Either<Failure, CvUploadReceipt?>? uploadResult;
  Either<Failure, CvPendingUpload?> pendingResult = const Right(null);
  Either<Failure, CvUploadReceipt?>? retryResult;
  Either<Failure, CvLocalFile?> localFileResult = const Right(null);

  @override
  Future<Either<Failure, CvUploadReceipt?>> uploadCv(
    CvUploadInput input, {
    void Function(int sentBytes, int totalBytes)? onSendProgress,
  }) async {
    return uploadResult!;
  }

  @override
  Future<Either<Failure, CvPendingUpload?>> getPendingCvUpload() async {
    return pendingResult;
  }

  @override
  Future<Either<Failure, CvUploadReceipt?>> retryPendingCvUpload() async {
    return retryResult!;
  }

  @override
  Future<Either<Failure, CvLocalFile?>> getLocalCvFile() async {
    return localFileResult;
  }
}

CvUploadInput testInput() => CvUploadInput(
  fileName: 'cv.pdf',
  extension: 'pdf',
  sizeBytes: 3,
  bytes: Uint8List.fromList([1, 2, 3]),
);

CvPendingUpload testPending() => CvPendingUpload(
  fileName: 'cv.pdf',
  extension: 'pdf',
  sizeBytes: 3,
  bytes: Uint8List.fromList([1, 2, 3]),
  userId: '7',
  savedAt: 1,
);

const _receipt = CvUploadReceipt(id: 2, version: 2, status: 'processing');

CvUploadCubit buildCubit(FakeCvRepository repo) => CvUploadCubit(
  uploadCvUseCase: UploadCvUseCase(repository: repo),
  getPendingCvUploadUseCase: GetPendingCvUploadUseCase(repository: repo),
  retryPendingCvUploadUseCase: RetryPendingCvUploadUseCase(repository: repo),
  getLocalCvFileUseCase: GetLocalCvFileUseCase(repository: repo),
  getCvStatusUseCase: GetCvStatusUseCase(repository: repo),
  getCvHistoryUseCase: GetCvHistoryUseCase(repository: repo),
  retryCvExtractionUseCase: RetryCvExtractionUseCase(repository: repo),
  verifyExtractionUseCase: VerifyExtractionUseCase(repository: repo),
  downloadCvUseCase: DownloadCvUseCase(repository: repo),
);

void main() {
  late FakeCvRepository repo;

  setUp(() {
    repo = FakeCvRepository();
  });

  group('CvUploadCubit', () {
    blocTest<CvUploadCubit, CvUploadState>(
      'emits [Uploading, Success] on upload success',
      build: () {
        repo.uploadResult = const Right(_receipt);
        return buildCubit(repo);
      },
      act: (cubit) => cubit.upload(testInput()),
      expect: () => const [
        CvUploading(),
        CvUploadSuccess(receipt: _receipt, fileName: 'cv.pdf'),
      ],
    );

    blocTest<CvUploadCubit, CvUploadState>(
      'emits Success with null receipt when the payload is incomplete',
      build: () {
        repo.uploadResult = const Right(null);
        return buildCubit(repo);
      },
      act: (cubit) => cubit.upload(testInput()),
      expect: () => const [
        CvUploading(),
        CvUploadSuccess(receipt: null, fileName: 'cv.pdf'),
      ],
    );

    blocTest<CvUploadCubit, CvUploadState>(
      'emits [Uploading, Failure] on upload failure',
      build: () {
        repo.uploadResult = const Left(ServerFailure(message: 'Upload failed'));
        return buildCubit(repo);
      },
      act: (cubit) => cubit.upload(testInput()),
      expect: () => const [
        CvUploading(),
        CvUploadFailure(message: 'Upload failed', canRetry: true),
      ],
    );

    blocTest<CvUploadCubit, CvUploadState>(
      'emits [Uploading, Failure] when offline with nothing pending',
      build: () {
        repo.uploadResult = const Left(OfflineFailure());
        repo.pendingResult = const Right(null);
        return buildCubit(repo);
      },
      act: (cubit) => cubit.upload(testInput()),
      expect: () => const [
        CvUploading(),
        CvUploadFailure(message: 'You are offline', canRetry: true),
      ],
    );

    blocTest<CvUploadCubit, CvUploadState>(
      'emits [Uploading, Pending] when offline and the file is stored',
      build: () {
        repo.uploadResult = const Left(OfflineFailure());
        repo.pendingResult = Right(testPending());
        return buildCubit(repo);
      },
      act: (cubit) => cubit.upload(testInput()),
      expect: () => const [CvUploading(), CvUploadPending(fileName: 'cv.pdf')],
    );

    blocTest<CvUploadCubit, CvUploadState>(
      'loadPending restores the pending state',
      build: () {
        repo.pendingResult = Right(testPending());
        return buildCubit(repo);
      },
      act: (cubit) => cubit.loadPending(),
      expect: () => const [CvUploadPending(fileName: 'cv.pdf')],
    );

    blocTest<CvUploadCubit, CvUploadState>(
      'loadPending stays initial when nothing is stored',
      build: () => buildCubit(repo),
      act: (cubit) => cubit.loadPending(),
      expect: () => isEmpty,
    );

    blocTest<CvUploadCubit, CvUploadState>(
      'retryPending uploads the stored file on success',
      build: () {
        repo.pendingResult = Right(testPending());
        repo.retryResult = const Right(_receipt);
        return buildCubit(repo);
      },
      seed: () => const CvUploadPending(fileName: 'cv.pdf'),
      act: (cubit) => cubit.retryPending(),
      expect: () => const [
        CvUploading(),
        CvUploadSuccess(receipt: _receipt, fileName: 'cv.pdf'),
      ],
    );

    blocTest<CvUploadCubit, CvUploadState>(
      'retryPending keeps pending when still offline',
      build: () {
        repo.pendingResult = Right(testPending());
        repo.retryResult = const Left(OfflineFailure());
        return buildCubit(repo);
      },
      seed: () => const CvUploadPending(fileName: 'cv.pdf'),
      act: (cubit) => cubit.retryPending(),
      expect: () => const [CvUploading(), CvUploadPending(fileName: 'cv.pdf')],
    );

    blocTest<CvUploadCubit, CvUploadState>(
      'retryLast re-sends the last failed attempt',
      build: () {
        repo.uploadResult = const Left(ServerFailure(message: 'Down'));
        return buildCubit(repo);
      },
      act: (cubit) async {
        await cubit.upload(testInput());
        repo.uploadResult = const Right(_receipt);
        repo.pendingResult = const Right(null);
        await cubit.retryLast();
      },
      expect: () => const [
        CvUploading(),
        CvUploadFailure(message: 'Down', canRetry: true),
        CvUploading(),
        CvUploadSuccess(receipt: _receipt, fileName: 'cv.pdf'),
      ],
    );

    blocTest<CvUploadCubit, CvUploadState>(
      'prevents duplicate upload requests',
      build: () {
        repo.uploadResult = const Right(_receipt);
        return buildCubit(repo);
      },
      seed: () => const CvUploading(),
      act: (cubit) => cubit.upload(testInput()),
      expect: () => isEmpty,
    );

    test('does nothing harmful when closed during upload', () async {
      repo.uploadResult = const Right(_receipt);
      final cubit = buildCubit(repo);
      await cubit.close();
      await cubit.upload(testInput());
      expect(cubit.state, const CvUploadInitial());
      await cubit.close();
    });
  });
}
