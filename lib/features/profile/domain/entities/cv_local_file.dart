import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// CV file bytes kept on this device for offline preview and retry.
///
/// Written whenever the user picks a CV (pending) or an upload
/// succeeds, scoped per authenticated user.
class CvLocalFile extends Equatable {
  const CvLocalFile({
    required this.fileName,
    required this.bytes,
    required this.userId,
    required this.savedAt,
  });

  final String fileName;
  final Uint8List bytes;

  /// Stringified [CacheKey.id] used to scope the record per user.
  final String userId;

  /// Epoch milliseconds of when the file was stored locally.
  final int savedAt;

  @override
  List<Object?> get props => [fileName, userId, savedAt];

  // --- `bytes` is intentionally excluded from props: `Uint8List`
  // --- uses identity equality, so two reads of the same stored file
  // --- would never compare equal and would break state comparisons. ---
}
