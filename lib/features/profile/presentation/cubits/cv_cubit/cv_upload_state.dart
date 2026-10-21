import 'package:MatchIn/features/profile/domain/entities/cv_extraction_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_upload_receipt.dart';
import 'package:equatable/equatable.dart';

sealed class CvUploadState extends Equatable {
  const CvUploadState();

  @override
  List<Object?> get props => [];
}

final class CvUploadInitial extends CvUploadState {
  const CvUploadInitial();
}

final class CvUploading extends CvUploadState {
  const CvUploading({this.progress = 0});

  /// 0..1 fraction from the networking layer; 0 while indeterminate.
  final double progress;

  @override
  List<Object?> get props => [progress];
}

/// A CV picked while offline and stored locally, waiting for upload.
final class CvUploadPending extends CvUploadState {
  const CvUploadPending({required this.fileName});

  final String fileName;

  @override
  List<Object?> get props => [fileName];
}

final class CvUploadSuccess extends CvUploadState {
  const CvUploadSuccess({this.receipt, this.fileName});

  /// Null when the upload succeeded but the response carried no
  /// usable receipt. The Main Profile still refreshes from GET.
  final CvUploadReceipt? receipt;

  /// Local filename of the uploaded file. The upload response
  /// carries no filename, so the UI falls back to this while the
  /// profile refresh lands.
  final String? fileName;

  @override
  List<Object?> get props => [receipt, fileName];
}

final class CvUploadFailure extends CvUploadState {
  const CvUploadFailure({required this.message, this.canRetry = false});

  final String message;

  /// True when the failed attempt bytes are still available for a
  /// one-tap retry without re-picking the file.
  final bool canRetry;

  @override
  List<Object?> get props => [message, canRetry];
}

/// Background extraction is being polled for [docId].
/// Upload acceptance (HTTP 201) is not completion: this state tracks
/// the follow-up status checks separately from the upload request.
/// [fileName] carries the locally known upload name forward so the card
/// never flashes back to the empty state while polling.
final class CvExtractionPolling extends CvUploadState {
  const CvExtractionPolling({
    required this.docId,
    this.attempts = 0,
    this.fileName,
  });

  final int docId;
  final int attempts;
  final String? fileName;

  @override
  List<Object?> get props => [docId, attempts, fileName];
}

/// Extraction finished with reviewable content (or none, when the
/// backend completed without parsed data).
final class CvExtractionCompleted extends CvUploadState {
  const CvExtractionCompleted({
    required this.docId,
    this.extraction,
    this.fileName,
  });

  final int docId;
  final CvExtractionEntity? extraction;
  final String? fileName;

  @override
  List<Object?> get props => [docId, extraction, fileName];
}

/// Extraction failed definitively (or polling timed out). [canRetry]
/// re-arms server-side extraction via `POST /cv/retry/{doc}` — distinct
/// from re-uploading the file.
final class CvExtractionFailed extends CvUploadState {
  const CvExtractionFailed({
    required this.docId,
    required this.message,
    this.canRetry = true,
    this.fileName,
  });

  final int docId;
  final String message;
  final bool canRetry;
  final String? fileName;

  @override
  List<Object?> get props => [docId, message, canRetry, fileName];
}

final class CvVerifying extends CvUploadState {
  const CvVerifying();
}

final class CvVerified extends CvUploadState {
  const CvVerified();
}

final class CvVerifyFailure extends CvUploadState {
  const CvVerifyFailure({required this.message, this.fieldErrors = const {}});

  final String message;

  /// Field-level validation messages from a 422 response, keyed by field.
  final Map<String, List<String>> fieldErrors;

  @override
  List<Object?> get props => [message];
}
