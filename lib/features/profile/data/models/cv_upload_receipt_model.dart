import 'package:MatchIn/features/profile/data/models/json_parsing.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_upload_receipt.dart';

class CvUploadReceiptModel extends CvUploadReceipt {
  const CvUploadReceiptModel({required super.id, super.version, super.status});

  /// Parses the `POST /cv/upload` envelope `{status, message, data:{...}}`.
  ///
  /// Supports the current JSON:API-style shape where the record id and
  /// `type` sit top-level inside `data` while `version`/`status` live
  /// under `data.attributes` (ids may be numeric strings such as
  /// `"10"`), as well as the legacy flat shape
  /// (`data:{id, version, status}` with numeric ids).
  /// Returns null when the mutation succeeded (2xx) but no usable
  /// receipt is present (missing/invalid id). Callers must refresh
  /// the Main Profile from GET instead of fabricating document data.
  static CvUploadReceiptModel? tryParseReceipt(dynamic response) {
    if (response is! Map<String, dynamic>) return null;
    final data = response['data'];
    if (data is! Map<String, dynamic>) return null;
    // Attributes override top-level keys when the new shape is present.
    final attributes = data['attributes'];
    final Map<String, dynamic> record = attributes is Map<String, dynamic>
        ? {...data, ...attributes}
        : data;
    final id = JsonParsing.parseId(record['id']);
    if (id == null || id <= 0) return null;
    return CvUploadReceiptModel(
      id: id,
      version: JsonParsing.parseId(record['version']),
      status: record['status']?.toString(),
    );
  }
}
