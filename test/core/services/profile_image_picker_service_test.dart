import 'dart:typed_data';

import 'package:MatchIn/core/services/profile_image_picker_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

class FakeImagePicker extends ImagePicker {
  XFile? nextResult;
  bool throwError = false;
  ImageSource? lastSource;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    lastSource = source;
    if (throwError) throw Exception('denied');
    return nextResult;
  }
}

XFile jpgFile() => XFile.fromData(
  Uint8List.fromList([1, 2, 3]),
  name: 'photo.jpg',
  path: 'photo.jpg',
  mimeType: 'image/jpeg',
);

void main() {
  group('ProfileImagePickerService', () {
    test('returns picked bytes for camera selection', () async {
      final picker = FakeImagePicker()..nextResult = jpgFile();
      final service = ProfileImagePickerService(imagePicker: picker);

      final file = await service.pickProfileImage(ImageSource.camera);

      expect(picker.lastSource, ImageSource.camera);
      expect(file, isNotNull);
      expect(file!.name, 'photo.jpg');
      expect(file.bytes, [1, 2, 3]);
    });

    test('returns picked bytes for gallery selection', () async {
      final picker = FakeImagePicker()..nextResult = jpgFile();
      final service = ProfileImagePickerService(imagePicker: picker);

      final file = await service.pickProfileImage(ImageSource.gallery);

      expect(picker.lastSource, ImageSource.gallery);
      expect(file, isNotNull);
    });

    test('returns null on picker cancellation', () async {
      final service = ProfileImagePickerService(imagePicker: FakeImagePicker());

      expect(await service.pickProfileImage(ImageSource.gallery), isNull);
    });

    test('returns null on platform errors', () async {
      final picker = FakeImagePicker()..throwError = true;
      final service = ProfileImagePickerService(imagePicker: picker);

      expect(await service.pickProfileImage(ImageSource.camera), isNull);
    });
  });
}
