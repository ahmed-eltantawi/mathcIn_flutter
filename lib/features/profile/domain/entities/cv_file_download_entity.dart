import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// Authenticated binary CV payload (preview/download).
///
/// Bytes are transient (temp-file preview) and never persisted to the
/// JSON cache; only metadata survives restarts.
class CvFileDownloadEntity extends Equatable {
  const CvFileDownloadEntity({
    required this.bytes,
    this.fileName,
    this.mimeType,
  });

  final Uint8List bytes;
  final String? fileName;
  final String? mimeType;

  bool get isPdf {
    final name = fileName?.toLowerCase() ?? '';
    final type = mimeType?.toLowerCase() ?? '';
    return type.contains('pdf') || name.endsWith('.pdf');
  }

  @override
  List<Object?> get props => [bytes, fileName, mimeType];
}
