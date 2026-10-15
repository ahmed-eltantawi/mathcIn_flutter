import 'dart:typed_data';

import 'package:MatchIn/core/services/picked_file.dart';
import 'package:file_picker/file_picker.dart';

class FilePickerService {
  Future<PlatformFile?> pickCv() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'docx'],
    );

    if (files.isEmpty) {
      return null;
    }

    return files.first;
  }

  /// Picks a CV and reads its content into memory.
  ///
  /// Returns null when the user dismisses the picker. A picked file
  /// whose content cannot be read is returned with empty bytes so
  /// validation rejects it with localized feedback instead of
  /// crashing or uploading nothing.
  Future<PickedFile?> pickCvBytes() async {
    final file = await pickCv();
    if (file == null) return null;

    try {
      final bytes = await file.readAsBytes();
      return PickedFile(name: file.name, bytes: bytes);
    } catch (_) {
      return PickedFile(name: file.name, bytes: Uint8List(0));
    }
  }
}
