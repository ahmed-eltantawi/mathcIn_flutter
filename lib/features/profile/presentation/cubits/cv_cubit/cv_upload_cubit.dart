import 'package:MatchIn/features/profile/domain/entities/cv_local_file.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_upload_input.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_local_cv_file_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_pending_cv_upload_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/retry_pending_cv_upload_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/upload_cv_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/cv_cubit/cv_upload_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CvUploadCubit extends Cubit<CvUploadState> {
  CvUploadCubit({
    required this.uploadCvUseCase,
    required this.getPendingCvUploadUseCase,
    required this.retryPendingCvUploadUseCase,
    required this.getLocalCvFileUseCase,
  }) : super(const CvUploadInitial());

  final UploadCvUseCase uploadCvUseCase;
  final GetPendingCvUploadUseCase getPendingCvUploadUseCase;
  final RetryPendingCvUploadUseCase retryPendingCvUploadUseCase;
  final GetLocalCvFileUseCase getLocalCvFileUseCase;

  /// Last attempted upload input, kept in memory for one-tap retry
  /// after a server failure. Never part of the emitted state.
  CvUploadInput? _lastAttempt;

  Future<void> upload(CvUploadInput input) async {
    if (isClosed || state is CvUploading) return;
    emit(const CvUploading());
    _lastAttempt = input;

    final result = await uploadCvUseCase(input);
    // --- Offline selections are stored as pending by the
    // --- repository: resolve it before emitting any failure. ---
    final pendingFileName = result.isLeft()
        ? await _pendingFileName()
        : null;
    if (isClosed) return;

    result.fold(
      (failure) {
        if (pendingFileName != null) {
          emit(CvUploadPending(fileName: pendingFileName));
          return;
        }
        emit(CvUploadFailure(message: failure.message, canRetry: true));
      },
      (receipt) {
        emit(CvUploadSuccess(receipt: receipt, fileName: input.fileName));
      },
    );
  }

  /// Restores the pending state (e.g. after navigation or restart)
  /// when a stored offline upload is waiting.
  Future<void> loadPending() async {
    if (isClosed || state is CvUploading) return;
    final pendingFileName = await _pendingFileName();
    if (isClosed) return;
    if (pendingFileName != null && state is CvUploadInitial) {
      emit(CvUploadPending(fileName: pendingFileName));
    }
  }

  /// Uploads the stored pending file. Keeps the pending state when
  /// still offline; surfaces success or failure otherwise.
  Future<void> retryPending() async {
    if (isClosed || state is CvUploading) return;
    final pendingFileName = await _pendingFileName();
    if (isClosed) return;
    if (pendingFileName == null) return;
    emit(const CvUploading());

    final result = await retryPendingCvUploadUseCase();
    final stillPendingFileName = result.isLeft()
        ? await _pendingFileName()
        : null;
    if (isClosed) return;

    result.fold(
      (failure) {
        if (stillPendingFileName != null) {
          emit(CvUploadPending(fileName: stillPendingFileName));
          return;
        }
        emit(CvUploadFailure(message: failure.message));
      },
      (receipt) {
        emit(CvUploadSuccess(receipt: receipt, fileName: pendingFileName));
      },
    );
  }

  /// Re-sends the last failed attempt without re-picking the file.
  /// Falls back to the locally cached file when memory was lost.
  Future<void> retryLast() async {
    if (isClosed || state is CvUploading) return;
    final attempt = _lastAttempt ?? await _attemptFromLocalFile();
    if (attempt == null) return;
    await upload(attempt);
  }

  /// Locally stored CV bytes for offline preview, if any.
  Future<CvLocalFile?> localFile() async {
    final result = await getLocalCvFileUseCase();
    return result.fold((_) => null, (file) => file);
  }

  Future<CvUploadInput?> _attemptFromLocalFile() async {
    final file = await localFile();
    if (file == null || file.bytes.isEmpty) return null;
    return CvUploadInput(
      fileName: file.fileName,
      extension: _extensionOf(file.fileName),
      sizeBytes: file.bytes.length,
      bytes: file.bytes,
    );
  }

  Future<String?> _pendingFileName() async {
    final result = await getPendingCvUploadUseCase();
    return result.fold(
      (_) => null,
      (pending) => pending?.fileName,
    );
  }

  String _extensionOf(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return '';
    return fileName.substring(dot + 1).toLowerCase();
  }
}
