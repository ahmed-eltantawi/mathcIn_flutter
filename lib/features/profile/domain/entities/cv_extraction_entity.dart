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
    this.institution,
    this.degree,
    this.fieldOfStudy,
    this.companyName,
    this.jobTitle,
    this.location,
    this.grade,
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
      institution: _stringOf(json, const ['institution', 'school']),
      degree: _stringOf(json, const ['degree']),
      fieldOfStudy: _stringOf(json, const ['field_of_study', 'fieldOfStudy']),
      companyName: _stringOf(json, const ['company_name', 'company']),
      jobTitle: _stringOf(json, const ['job_title']),
      location: _stringOf(json, const ['location']),
      grade: _stringOf(json, const ['grade']),
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
  final String? institution;
  final String? degree;
  final String? fieldOfStudy;
  final String? companyName;
  final String? jobTitle;
  final String? location;
  final String? grade;
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

  Map<String, dynamic> toSkillVerifyJson() => {
    if (name != null && name!.trim().isNotEmpty) 'name': name!.trim(),
    if (proficiency != null && proficiency!.trim().isNotEmpty)
      'proficiency_level': proficiency!.trim().toLowerCase(),
  };

  Map<String, dynamic> toEducationVerifyJson() => {
    if (institution != null && institution!.trim().isNotEmpty)
      'institution': institution!.trim(),
    if (degree != null && degree!.trim().isNotEmpty) 'degree': degree!.trim(),
    if (fieldOfStudy != null && fieldOfStudy!.trim().isNotEmpty)
      'field_of_study': fieldOfStudy!.trim(),
    if (startDate != null && startDate!.trim().isNotEmpty)
      'start_date': startDate!.trim(),
    if (endDate != null && endDate!.trim().isNotEmpty)
      'end_date': endDate!.trim(),
    if (isCurrent != null) 'is_current': isCurrent,
    if (grade != null && grade!.trim().isNotEmpty) 'grade': grade!.trim(),
  };

  Map<String, dynamic> toExperienceVerifyJson() => {
    if (companyName != null && companyName!.trim().isNotEmpty)
      'company_name': companyName!.trim(),
    if (jobTitle != null && jobTitle!.trim().isNotEmpty)
      'job_title': jobTitle!.trim(),
    if (startDate != null && startDate!.trim().isNotEmpty)
      'start_date': startDate!.trim(),
    if (endDate != null && endDate!.trim().isNotEmpty)
      'end_date': endDate!.trim(),
    if (isCurrent != null) 'is_current': isCurrent,
    if (detail != null && detail!.trim().isNotEmpty)
      'description': detail!.trim(),
    if (location != null && location!.trim().isNotEmpty)
      'location': location!.trim(),
  };

  bool get isSkillComplete =>
      name?.trim().isNotEmpty == true &&
      const {
        'beginner',
        'intermediate',
        'advanced',
        'expert',
      }.contains(proficiency?.trim().toLowerCase());

  bool get isEducationComplete =>
      institution?.trim().isNotEmpty == true &&
      degree?.trim().isNotEmpty == true &&
      fieldOfStudy?.trim().isNotEmpty == true &&
      _hasIsoDate(startDate);

  bool get isExperienceComplete =>
      companyName?.trim().isNotEmpty == true &&
      jobTitle?.trim().isNotEmpty == true &&
      _hasIsoDate(startDate);

  static bool _hasIsoDate(String? value) =>
      value != null && RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value.trim());

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
    institution,
    degree,
    fieldOfStudy,
    companyName,
    jobTitle,
    location,
    grade,
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
