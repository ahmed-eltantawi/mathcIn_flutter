import 'package:equatable/equatable.dart';

/// Remembers a successful CV upload until the backend profile read
/// catches up with it.
///
/// The `POST /cv/upload` response carries only a receipt
/// (`id`, `version`, `status`) without filename or file URL, so the
/// marker keeps the local filename next to the receipt. While the
/// marker exists and the remote profile has no matching current CV,
/// the repository serves the marker-derived document instead of an
/// empty CV state. The marker is cleared once the remote profile
/// contains the uploaded document.
class CvUploadMarker extends Equatable {
  const CvUploadMarker({
    this.id,
    required this.fileName,
    this.version,
    this.status,
    required this.uploadedAt,
    required this.userId,
  });

  /// Receipt id from the upload response. Null when the 2xx response
  /// carried no usable receipt.
  final int? id;
  final String fileName;
  final int? version;

  /// Raw backend status token (e.g. `uploaded`, `processing`).
  final String? status;

  /// Epoch milliseconds of the successful upload.
  final int uploadedAt;

  /// Stringified [CacheKey.id] used to scope the record per user.
  final String userId;

  @override
  List<Object?> get props => [
    id,
    fileName,
    version,
    status,
    uploadedAt,
    userId,
  ];
}
