import 'dart:typed_data';

import 'package:equatable/equatable.dart';

/// Platform-independent avatar upload input.
///
/// The Presentation layer maps the picked image into this entity so the
/// Domain and Data layers never depend on image picking or `dart:io`:
/// file content always travels as in-memory [bytes], which works on
/// mobile and web alike.
class AvatarUploadInput extends Equatable {
  const AvatarUploadInput({required this.fileName, required this.bytes});

  final String fileName;
  final Uint8List bytes;

  @override
  List<Object?> get props => [fileName, bytes];
}
