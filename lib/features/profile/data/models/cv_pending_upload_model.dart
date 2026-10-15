import 'dart:convert';
import 'dart:typed_data';

import 'package:MatchIn/features/profile/domain/entities/cv_pending_upload.dart';

class CvPendingUploadModel extends CvPendingUpload {
  const CvPendingUploadModel({
    required super.fileName,
    required super.extension,
    required super.sizeBytes,
    required super.bytes,
    required super.userId,
    required super.savedAt,
  });

  factory CvPendingUploadModel.fromEntity(CvPendingUpload entity) {
    return CvPendingUploadModel(
      fileName: entity.fileName,
      extension: entity.extension,
      sizeBytes: entity.sizeBytes,
      bytes: entity.bytes,
      userId: entity.userId,
      savedAt: entity.savedAt,
    );
  }

  factory CvPendingUploadModel.fromJson(Map<String, dynamic> json) {
    final rawBytes = json['bytes'];
    return CvPendingUploadModel(
      fileName: (json['fileName'] ?? '').toString(),
      extension: (json['extension'] ?? '').toString(),
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      bytes: rawBytes is String && rawBytes.isNotEmpty
          ? Uint8List.fromList(base64Decode(rawBytes))
          : Uint8List(0),
      userId: (json['userId'] ?? '').toString(),
      savedAt: (json['savedAt'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'extension': extension,
      'sizeBytes': sizeBytes,
      'bytes': base64Encode(bytes),
      'userId': userId,
      'savedAt': savedAt,
    };
  }
}
