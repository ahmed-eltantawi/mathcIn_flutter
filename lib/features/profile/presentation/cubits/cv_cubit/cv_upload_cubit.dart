import 'dart:async';

import 'package:MatchIn/core/errors/failures.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_file_download_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_local_file.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_processing_status.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_upload_input.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_verify_params.dart';
import 'package:MatchIn/features/profile/domain/use_cases/download_cv_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_cv_history_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_cv_status_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_local_cv_file_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/get_pending_cv_upload_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/retry_cv_extraction_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/retry_pending_cv_upload_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/upload_cv_use_case.dart';
import 'package:MatchIn/features/profile/domain/use_cases/verify_extraction_use_case.dart';
import 'package:MatchIn/features/profile/presentation/cubits/cv_cubit/cv_upload_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CvUploadCubit extends Cubit<CvUploadState> {
  CvUploadCubit({
    required this.uploadCvUseCase,
    required this.getPendingCvUploadUseCase,
    required this.retryPendingCvUploadUseCase,
    required this.getLocalCvFileUseCase,
    required this.getCvStatusUseCase,
    required this.getCvHistoryUseCase,
    required this.retryCvExtractionUseCase,
    required this.verifyExtractionUseCase,
    required this.downloadCvUseCase,
    this.pollInterval = const Duration(seconds: 3),
  }) : super(const CvUploadInitial());

  final UploadCvUseCase uploadCvUseCase;
  final GetPendingCvUploadUseCase getPendingCvUploadUseCase;
  final RetryPendingCvUploadUseCase retryPendingCvUploadUseCase;
  final GetLocalCvFileUseCase getLocalCvFileUseCase;
  final GetCvStatusUseCase getCvStatusUseCase;
  final GetCvHistoryUseCase getCvHistoryUseCase;
  final RetryCvExtractionUseCase retryCvExtractionUseCase;
  final VerifyExtractionUseCase verifyExtractionUseCase;
  final DownloadCvUseCase downloadCvUseCase;

  /// Status-poll interval (3s production; shortened in tests).
  final Duration pollInterval;

  /// Last attempted upload input, kept in memory for one-tap retry
  /// after a server failure. Never part of the emitted state.
  CvUploadInput? _lastAttempt;

  /// Bounded extraction polling: 3s interval, 20 attempts (~60s), then
  /// a terminal failure with server-side retry available. Cancelled on
  /// close, on terminal states, and when superseded by a newer watch.
  Timer? _pollTimer;
  static const int _maxPollAttempts = 20;

  Future<void> upload(CvUploadInput input) async {
    if (isClosed || state is CvUploading) return;
    emit(const CvUploading());
    _lastAttempt = input;

    final result = await uploadCvUseCase(
      input,
      onSendProgress: (sent, total) {
        if (isClosed || total <= 0) return;
        emit(CvUploading(progress: (sent / total).clamp(0.0, 1.0)));
      },
    );
    // --- Offline selections are stored as pending by the
    // --- repository: resolve it before emitting any failure. ---
    final pendingFileName = result.isLeft() ? await _pendingFileName() : null;
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

  /// Newest history document id, used to adopt a real id after a
  /// receipt-less upload acceptance. Null when history is unavailable.
  Future<int?> latestHistoryDocId() async {
    final result = await getCvHistoryUseCase();
    return result.fold((_) => null, (documents) {
      for (final doc in documents) {
        if (doc.id != null) return doc.id;
      }
      return null;
    });
  }

  /// Starts (or restarts) bounded polling of background extraction for
  /// [docId]. Emits terminal states exactly once; safe to call on
  /// every reconnect or foreground return. [fileName] is the locally
  /// known upload name, carried through every polling state so the UI
  /// never flashes back to empty while the profile refresh lands.
  Future<void> watchExtraction(int docId, {String? fileName}) async {
    _pollTimer?.cancel();
    _pollTimer = null;
    if (isClosed) return;
    emit(CvExtractionPolling(docId: docId, fileName: fileName));
    await _pollOnce(docId, 1, fileName: fileName);
    if (isClosed) return;
    if (state is! CvExtractionPolling) return;
    var attempts = 1;
    _pollTimer = Timer.periodic(pollInterval, (timer) async {
      attempts++;
      if (attempts > _maxPollAttempts) {
        timer.cancel();
        _pollTimer = null;
        if (!isClosed && state is CvExtractionPolling) {
          emit(
            CvExtractionFailed(
              docId: docId,
              message: 'Extraction timed out.',
              fileName: fileName,
            ),
          );
        }
        return;
      }
      await _pollOnce(docId, attempts, fileName: fileName);
      if (isClosed) return;
      if (state is! CvExtractionPolling) {
        timer.cancel();
        _pollTimer = null;
      }
    });
  }

  /// Re-arms server-side extraction for a failed document, then resumes
  /// polling. Distinct from re-uploading the file.
  Future<void> retryExtraction(int docId) async {
    if (isClosed) return;
    _pollTimer?.cancel();
    _pollTimer = null;
    final fileName = _currentFileName();
    final result = await retryCvExtractionUseCase(docId);
    if (isClosed) return;
    final accepted = result.isRight();
    if (!accepted) {
      final failure = (result as Left).value;
      emit(
        CvExtractionFailed(
          docId: docId,
          message: failure.message,
          canRetry: failure is! OfflineFailure,
          fileName: fileName,
        ),
      );
      return;
    }
    await watchExtraction(docId, fileName: fileName);
  }

  /// Submits reviewed extraction data with the real backend id.
  /// User edits live in the form (UI) and are preserved on failure
  /// because the sheet only closes on [CvVerified].
  Future<void> verifyExtraction(CvVerifyParams params) async {
    if (isClosed || state is CvVerifying) return;
    if (params.extractionId == null) return;
    emit(const CvVerifying());
    final result = await verifyExtractionUseCase(params);
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        CvVerifyFailure(
          message: failure.message,
          fieldErrors: failure is ServerFailure
              ? failure.fieldErrors
              : const {},
        ),
      ),
      (_) => emit(const CvVerified()),
    );
  }

  /// Authenticated binary fetch for preview. Returns null offline, on
  /// empty payloads, or on failures (callers show localized errors).
  /// Bytes stay transient: only metadata is ever persisted elsewhere.
  Future<CvFileDownloadEntity?> downloadRemote({int? cvDocumentId}) async {
    final result = await downloadCvUseCase(cvDocumentId: cvDocumentId);
    return result.fold((_) => null, (file) => file);
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    _pollTimer = null;
    return super.close();
  }

  Future<void> _pollOnce(int docId, int attempts, {String? fileName}) async {
    final result = await getCvStatusUseCase(docId);
    if (isClosed) return;
    result.fold(
      (failure) {
        if (state is! CvExtractionPolling) return;
        if (failure is OfflineFailure) return;
        emit(
          CvExtractionFailed(
            docId: docId,
            message: failure.message,
            fileName: fileName,
          ),
        );
      },
      (status) {
        if (state is! CvExtractionPolling) return;
        final statusValue = status.status;
        // Non-terminal (including undocumented tokens): keep polling
        // until the attempt budget runs out.
        if (statusValue == null ||
            statusValue == CvProcessingStatus.unknown ||
            !status.isTerminal) {
          emit(
            CvExtractionPolling(
              docId: docId,
              attempts: attempts,
              fileName: fileName,
            ),
          );
          return;
        }
        if (statusValue == CvProcessingStatus.failed) {
          emit(
            CvExtractionFailed(
              docId: docId,
              message: _nonEmpty(status.errorMessage) ?? 'Extraction failed.',
              fileName: fileName,
            ),
          );
          return;
        }
        emit(
          CvExtractionCompleted(
            docId: docId,
            extraction: status.extraction,
            fileName: fileName,
          ),
        );
      },
    );
  }

  /// Locally known upload name from the current state, if any.
  String? _currentFileName() {
    final current = state;
    if (current is CvUploadSuccess) return current.fileName;
    if (current is CvExtractionPolling) return current.fileName;
    if (current is CvExtractionCompleted) return current.fileName;
    if (current is CvExtractionFailed) return current.fileName;
    return null;
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
    return result.fold((_) => null, (pending) => pending?.fileName);
  }

  String _extensionOf(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return '';
    return fileName.substring(dot + 1).toLowerCase();
  }

  String? _nonEmpty(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
