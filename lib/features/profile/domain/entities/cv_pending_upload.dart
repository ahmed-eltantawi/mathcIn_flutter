import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// A CV file selected while offline and waiting for upload.
///
/// Stored per authenticated user so it survives app restarts and is
/// never shown to another account. Cleared once the upload succeeds.
class CvPendingUpload extends Equatable {
  const CvPendingUpload({
    required this.fileName,
    required this.extension,
    required this.sizeBytes,
    required this.bytes,
    required this.userId,
    required this.savedAt,
  });

  final String fileName;
  final String extension;
  final int sizeBytes;
  final Uint8List bytes;

  /// Stringified [CacheKey.id] used to scope the record per user.
  /// Empty when no user id was available at save time.
  final String userId;

  /// Epoch milliseconds of when the file was stored locally.
  final int savedAt;

  @override
  List<Object?> get props => [fileName, extension, sizeBytes, userId, savedAt];

  // --- `bytes` is intentionally excluded from props: `Uint8List`
  // --- uses identity equality, so two reads of the same stored file
  // --- would never compare equal and would break state comparisons. ---
}
