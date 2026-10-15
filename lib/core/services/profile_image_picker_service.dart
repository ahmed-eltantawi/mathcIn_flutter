import 'package:MatchIn/core/services/picked_file.dart';
import 'package:image_picker/image_picker.dart' hide PickedFile;

/// Picks profile images from the camera or gallery.
///
/// Separate from the document `FilePickerService`, which is
/// intentionally left untouched: image capture needs platform
/// camera/gallery support that document picking does not provide.
class ProfileImagePickerService {
  ProfileImagePickerService({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  /// Returns the picked image as in-memory bytes, or null when the
  /// user dismisses the picker or the platform reports an error.
  /// A null result always means "no image", never a failure to report.
  Future<PickedFile?> pickProfileImage(ImageSource source) async {
    try {
      final file = await _imagePicker.pickImage(source: source);
      if (file == null) return null;
      final bytes = await file.readAsBytes();
      return PickedFile(name: file.name, bytes: bytes);
    } catch (_) {
      return null;
    }
  }
}
