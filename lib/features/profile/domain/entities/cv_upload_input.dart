import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// Platform-independent CV upload input.
///
/// The Presentation layer maps the picked file into this entity so the
/// Domain and Data layers never depend on file picking or `dart:io`:
/// file content always travels as in-memory [bytes], which works on
/// mobile and web alike.
class CvUploadInput extends Equatable {
  const CvUploadInput({
    required this.fileName,
    required this.extension,
    required this.sizeBytes,
    required this.bytes,
  });

  final String fileName;
  final String extension;
  final int sizeBytes;
  final Uint8List bytes;

  @override
  List<Object?> get props => [fileName, extension, sizeBytes, bytes];
}
