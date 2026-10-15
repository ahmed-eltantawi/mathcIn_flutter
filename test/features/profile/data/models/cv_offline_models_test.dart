import 'dart:typed_data';

import 'package:MatchIn/features/profile/data/models/cv_local_file_model.dart';
import 'package:MatchIn/features/profile/data/models/cv_pending_upload_model.dart';
import 'package:MatchIn/features/profile/data/models/cv_upload_marker_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CV offline models', () {
    test('pending upload round-trips bytes through base64', () {
      final withBytes = CvPendingUploadModel(
        fileName: 'my-cv.pdf',
        extension: 'pdf',
        sizeBytes: 4,
        bytes: Uint8List.fromList([1, 2, 3, 4]),
        userId: '7',
        savedAt: 1,
      );
      final restored = CvPendingUploadModel.fromJson(withBytes.toJson());

      expect(restored.fileName, 'my-cv.pdf');
      expect(restored.bytes, [1, 2, 3, 4]);
      expect(restored.userId, '7');
    });

    test('upload marker round-trips a receipt-less upload', () {
      const marker = CvUploadMarkerModel(
        fileName: 'my-cv.pdf',
        uploadedAt: 5,
        userId: '7',
      );
      final restored = CvUploadMarkerModel.fromJson(marker.toJson());

      expect(restored.id, isNull);
      expect(restored.fileName, 'my-cv.pdf');
      expect(restored.uploadedAt, 5);
    });

    test('cached file round-trips content', () {
      final file = CvLocalFileModel(
        fileName: 'my-cv.pdf',
        bytes: Uint8List.fromList([9, 8]),
        userId: '7',
        savedAt: 2,
      );
      final restored = CvLocalFileModel.fromJson(file.toJson());

      expect(restored.fileName, 'my-cv.pdf');
      expect(restored.bytes, [9, 8]);
    });
  });
}
