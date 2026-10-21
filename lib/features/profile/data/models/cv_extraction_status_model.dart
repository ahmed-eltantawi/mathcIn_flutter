import 'package:MatchIn/features/profile/data/models/json_parsing.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_extraction_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_extraction_status_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_processing_status.dart';

/// Parses `GET /cv/status/{cvDocument}` (`{data: {...}}`).
///
/// Documented payload keys: `id`, `candidate_id`, `file_name`, `status`,
/// `parsed_data`, `error_message`, `created_at`. The nested `extraction`
/// object (with its own id and confidence payload) is honored when the
/// backend provides one instead of a flat `parsed_data`.
/// Backend machine string → domain enum. Documented values
/// (`uploaded`, `processing`, `completed`, `failed`) plus their
/// identical UI tokens map to known states; everything else is
/// [unknown]. `uploaded` means the file reached the server and is
/// awaiting analysis, so it maps to [analyzing] — an HTTP upload
/// failure is reported separately through `CvUploadFailure` and
/// must not be confused with analysis status.
class CvExtractionStatusModel extends CvExtractionStatusEntity {
  const CvExtractionStatusModel({
    super.documentId,
    super.status,
    super.extraction,
    super.errorMessage,
    super.fileName,
  });

  factory CvExtractionStatusModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final Map<String, dynamic> record = data is Map<String, dynamic>
        ? data
        : json;
    final extractionRaw = record['extraction'];
    final Map<String, dynamic>? extractionMap =
        extractionRaw is Map<String, dynamic> ? extractionRaw : null;
    final parsedRaw = record['parsed_data'] ?? extractionMap?['parsed_data'];
    final Map<String, dynamic> parsedMap = parsedRaw is Map<String, dynamic>
        ? parsedRaw
        : const {};

    return CvExtractionStatusModel(
      documentId: JsonParsing.parseId(record['id']),
      status: _statusFrom(JsonParsing.parseString(record['status'])),
      extraction: _extractionFrom(parsedMap, extractionMap, record['id']),
      errorMessage: (record['error_message'] ?? record['errorMessage'])
          ?.toString(),
      fileName: (record['file_name'] ?? record['fileName'])?.toString(),
    );
  }

  static CvExtractionEntity? _extractionFrom(
    Map<String, dynamic> parsed,
    Map<String, dynamic>? extractionMap,
    dynamic documentId,
  ) {
    if (parsed.isEmpty && extractionMap == null) return null;
    List<CvExtractedItem> itemsOf(dynamic value) {
      if (value is! List) return const [];
      return value
          .whereType<Map<String, dynamic>>()
          .map(CvExtractedItem.fromJson)
          .where((item) => item.label.isNotEmpty)
          .toList();
    }

    // Skills may arrive as objects or bare strings.
    final rawSkills = parsed['skills'] ?? parsed['verified_skills'];
    final List<CvExtractedItem> skills;
    if (rawSkills is List) {
      skills = [
        for (final entry in rawSkills)
          if (entry is Map<String, dynamic>)
            CvExtractedItem.fromJson(entry)
          else if (entry is String && entry.trim().isNotEmpty)
            CvExtractedItem(name: entry.trim()),
      ].where((item) => item.label.isNotEmpty).toList();
    } else {
      skills = const [];
    }

    final extraction = CvExtractionEntity(
      extractionId:
          extractionMap?['id'] ??
          extractionMap?['extraction_id'] ??
          parsed['extraction_id'],
      skills: skills,
      experiences: itemsOf(
        parsed['experiences'] ??
            parsed['verified_experiences'] ??
            parsed['work_experience'],
      ),
      educations: itemsOf(
        parsed['educations'] ??
            parsed['verified_educations'] ??
            parsed['education'],
      ),
      confidenceScore: _doubleOf(
        parsed['confidence_score'] ??
            extractionMap?['confidence_score'] ??
            extractionMap?['confidence'],
      ),
      raw: parsed,
    );
    if (!extraction.hasReviewableContent && extraction.extractionId == null) {
      return null;
    }
    return extraction;
  }

  static double? _doubleOf(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  static CvProcessingStatus? _statusFrom(String? value) {
    if (value == null) return null;
    switch (value.trim().toLowerCase()) {
      case 'processing':
      case 'uploaded':
      case 'analyzing':
        return CvProcessingStatus.analyzing;
      case 'completed':
      case 'analyzed':
        return CvProcessingStatus.analyzed;
      case 'failed':
        return CvProcessingStatus.failed;
      default:
        return CvProcessingStatus.unknown;
    }
  }
}
