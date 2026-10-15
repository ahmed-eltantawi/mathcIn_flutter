import 'dart:typed_data';

import 'package:MatchIn/features/profile/data/models/cv_upload_payload.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_upload_input.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CvUploadPayload.formData', () {
    test('uses the cv multipart field name with the file name', () {
      final payload = CvUploadPayload.formData(
        CvUploadInput(
          fileName: 'my-cv.pdf',
          extension: 'pdf',
          sizeBytes: 4,
          bytes: Uint8List.fromList([1, 2, 3, 4]),
        ),
      );

      expect(payload.keys, ['cv']);
      final file = payload['cv'] as MultipartFile;
      expect(file.filename, 'my-cv.pdf');
      expect(file.length, 4);
    });
  });
}
