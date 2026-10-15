import 'package:MatchIn/features/profile/data/models/json_parsing.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_upload_marker.dart';

class CvUploadMarkerModel extends CvUploadMarker {
  const CvUploadMarkerModel({
    super.id,
    required super.fileName,
    super.version,
    super.status,
    required super.uploadedAt,
    required super.userId,
  });

  factory CvUploadMarkerModel.fromEntity(CvUploadMarker entity) {
    return CvUploadMarkerModel(
      id: entity.id,
      fileName: entity.fileName,
      version: entity.version,
      status: entity.status,
      uploadedAt: entity.uploadedAt,
      userId: entity.userId,
    );
  }

  factory CvUploadMarkerModel.fromJson(Map<String, dynamic> json) {
    return CvUploadMarkerModel(
      id: JsonParsing.parseId(json['id']),
      fileName: (json['fileName'] ?? '').toString(),
      version: JsonParsing.parseId(json['version']),
      status: JsonParsing.parseString(json['status']),
      uploadedAt: (json['uploadedAt'] as num?)?.toInt() ?? 0,
      userId: (json['userId'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'version': version,
      'status': status,
      'uploadedAt': uploadedAt,
      'userId': userId,
    };
  }
}
