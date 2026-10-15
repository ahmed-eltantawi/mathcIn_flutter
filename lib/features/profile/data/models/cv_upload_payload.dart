import 'package:MatchIn/features/profile/domain/entities/cv_upload_input.dart';
import 'package:dio/dio.dart';

/// Builds the multipart payload for `POST /cv/upload`.
///
/// Field name `cv` follows the documented contract. File content always
/// travels as in-memory bytes ([CvUploadInput.bytes]) so uploads work
/// on mobile and web without `dart:io`.
class CvUploadPayload {
  const CvUploadPayload._();

  static Map<String, dynamic> formData(CvUploadInput input) {
    return {
      'cv': MultipartFile.fromBytes(input.bytes, filename: input.fileName),
    };
  }
}
