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
  const CvUploading();
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
