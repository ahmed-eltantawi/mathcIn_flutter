import 'package:equatable/equatable.dart';

/// One extracted item (skill, experience, or education) as parsed from
/// `parsed_data`. Field names vary by backend version, so every accessor
/// falls back through the documented aliases.
class CvExtractedItem extends Equatable {
  const CvExtractedItem({
    this.name,
    this.title,
    this.subtitle,
    this.detail,
    this.proficiency,
    this.isCurrent,
    this.startDate,
    this.endDate,
  });

  factory CvExtractedItem.fromJson(Map<String, dynamic> json) {
    return CvExtractedItem(
      name: _stringOf(json, const ['name', 'skill', 'skill_name']),
      title: _stringOf(json, const [
        'title',
        'job_title',
        'degree',
        'institution',
        'company_name',
      ]),
      subtitle: _stringOf(json, const [
        'company_name',
        'company',
        'institution',
        'school',
      ]),
      detail: _stringOf(json, const ['description', 'summary']),
      proficiency: _stringOf(json, const [
        'proficiency_level',
        'proficiency',
        'level',
      ]),
      isCurrent: _boolOf(json['is_current'] ?? json['isCurrent']),
      startDate: _stringOf(json, const ['start_date', 'startDate']),
      endDate: _stringOf(json, const ['end_date', 'endDate']),
    );
  }

  final String? name;
  final String? title;
  final String? subtitle;
  final String? detail;
  final String? proficiency;
  final bool? isCurrent;
  final String? startDate;
  final String? endDate;

  /// Human-readable primary label for display and verification payloads.
  String get label {
    for (final candidate in [name, title]) {
      if (candidate != null && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }
    return '';
  }

  Map<String, dynamic> toVerifyJson() {
    return {
      if (name != null && name!.trim().isNotEmpty) 'name': name!.trim(),
      if (title != null && title!.trim().isNotEmpty) 'title': title!.trim(),
      if (subtitle != null && subtitle!.trim().isNotEmpty)
        'company_name': subtitle!.trim(),
      if (detail != null && detail!.trim().isNotEmpty)
        'description': detail!.trim(),
      if (proficiency != null && proficiency!.trim().isNotEmpty)
        'proficiency_level': proficiency!.trim(),
      if (isCurrent != null) 'is_current': isCurrent,
      if (startDate != null && startDate!.trim().isNotEmpty)
        'start_date': startDate!.trim(),
      if (endDate != null && endDate!.trim().isNotEmpty)
        'end_date': endDate!.trim(),
    };
  }

  static String? _stringOf(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
      if (value is num) return value.toString();
    }
    return null;
  }

  static bool? _boolOf(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    name,
    title,
    subtitle,
    detail,
    proficiency,
    isCurrent,
    startDate,
    endDate,
  ];
}

/// Extracted CV payload held for candidate review before verification.
///
/// Never invents an extraction id: [extractionId] stays null unless the
/// backend supplies one, and verification refuses to run without it.
class CvExtractionEntity extends Equatable {
  const CvExtractionEntity({
    this.extractionId,
    this.skills = const [],
    this.experiences = const [],
    this.educations = const [],
    this.confidenceScore,
    this.raw = const {},
  });

  final dynamic extractionId;
  final List<CvExtractedItem> skills;
  final List<CvExtractedItem> experiences;
  final List<CvExtractedItem> educations;
  final double? confidenceScore;
  final Map<String, dynamic> raw;

  bool get hasReviewableContent =>
      skills.isNotEmpty || experiences.isNotEmpty || educations.isNotEmpty;

  @override
  List<Object?> get props => [
    extractionId,
    skills,
    experiences,
    educations,
    confidenceScore,
  ];
}
