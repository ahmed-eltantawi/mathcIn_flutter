import 'dart:convert';
import 'dart:typed_data';

import 'package:MatchIn/features/profile/domain/entities/cv_local_file.dart';

class CvLocalFileModel extends CvLocalFile {
  const CvLocalFileModel({
    required super.fileName,
    required super.bytes,
    required super.userId,
    required super.savedAt,
  });

  factory CvLocalFileModel.fromEntity(CvLocalFile entity) {
    return CvLocalFileModel(
      fileName: entity.fileName,
      bytes: entity.bytes,
      userId: entity.userId,
      savedAt: entity.savedAt,
    );
  }

  factory CvLocalFileModel.fromJson(Map<String, dynamic> json) {
    final rawBytes = json['bytes'];
    return CvLocalFileModel(
      fileName: (json['fileName'] ?? '').toString(),
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
      'bytes': base64Encode(bytes),
      'userId': userId,
      'savedAt': savedAt,
    };
  }
}
