import 'package:MatchIn/features/profile/data/models/json_parsing.dart';
import 'package:MatchIn/features/profile/domain/entities/experience_entity.dart';

class ExperienceModel extends ExperienceEntity {
  const ExperienceModel({
    required super.id,
    required super.jobTitle,
    required super.companyName,
    super.employmentType,
    super.country,
    super.city,
    super.description,
    super.technologies,
    super.startDate,
    super.endDate,
    super.isCurrent,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: JsonParsing.parseId(json['id']) ?? 0,
      jobTitle:
          (json['job_title'] ?? json['jobTitle'] ?? json['title'])
              ?.toString() ??
          '',
      companyName:
          (json['company_name'] ??
                  json['companyName'] ??
                  json['company'] ??
                  json['organization'])
              ?.toString() ??
          '',
      employmentType: (json['employment_type'] ?? json['employmentType'])
          ?.toString(),
      country: json['country']?.toString(),
      city: json['city']?.toString(),
      description: json['description']?.toString(),
      technologies: JsonParsing.parseStringList(json['technologies']),
      startDate: (json['start_date'] ?? json['startDate'])?.toString(),
      endDate: (json['end_date'] ?? json['endDate'])?.toString(),
      isCurrent:
          JsonParsing.parseBoolFlag(
            json['is_current'] ?? json['isCurrent'] ?? json['is_current_role'],
          ) ??
          false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'job_title': jobTitle,
      'company_name': companyName,
      'employment_type': employmentType,
      'country': country,
      'city': city,
      'description': description,
      'technologies': technologies,
      'start_date': startDate,
      'end_date': endDate,
      'is_current': isCurrent,
    };
  }

  /// Strict parser for POST/PATCH mutation responses.
  ///
  /// Returns null when the payload is not a complete record: an
  /// invalid `id`, or a blank `company_name`/`job_title` (the identity
  /// pair every complete record carries). Callers must treat null as
  /// "mutation accepted but payload unusable" and refresh from GET
  /// instead of replacing list data with defaults.
  static ExperienceModel? tryParseMutation(Map<String, dynamic> json) {
    final id = JsonParsing.parseId(json['id']) ?? 0;
    if (id <= 0) return null;

    final companyName =
        (json['company_name'] ??
                json['companyName'] ??
                json['company'] ??
                json['organization'])
            ?.toString()
            .trim() ??
        '';
    if (companyName.isEmpty) return null;

    final jobTitle =
        (json['job_title'] ?? json['jobTitle'] ?? json['title'])
            ?.toString()
            .trim() ??
        '';
    if (jobTitle.isEmpty) return null;

    return ExperienceModel.fromJson(json);
  }
}
