import 'package:MatchIn/features/profile/data/models/json_parsing.dart';
import 'package:MatchIn/features/profile/domain/entities/education_entity.dart';

class EducationModel extends EducationEntity {
  const EducationModel({
    required super.id,
    required super.degree,
    required super.institution,
    super.educationLevel,
    super.fieldOfStudy,
    super.isCurrent,
    super.description,
    super.source,
    super.startDate,
    super.endDate,
    super.grade,
  });

  factory EducationModel.fromJson(Map<String, dynamic> json) {
    return EducationModel(
      id: JsonParsing.parseId(json['id']) ?? 0,
      degree:
          (json['degree'] ?? json['degree_name'] ?? json['title'])
              ?.toString() ??
          '',
      institution:
          (json['institution'] ??
                  json['school'] ??
                  json['university'] ??
                  json['university_name'])
              ?.toString() ??
          '',
      educationLevel: (json['education_level'] ?? json['educationLevel'])
          ?.toString(),
      fieldOfStudy:
          (json['field_of_study'] ?? json['fieldOfStudy'] ?? json['field'])
              ?.toString(),
      isCurrent:
          JsonParsing.parseBoolFlag(json['is_current'] ?? json['isCurrent']) ??
          false,
      description: json['description']?.toString(),
      source: json['source']?.toString(),
      startDate: (json['start_date'] ?? json['startDate'])?.toString(),
      endDate: (json['end_date'] ?? json['endDate'])?.toString(),
      grade: json['grade']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'degree': degree,
      'institution': institution,
      'education_level': educationLevel,
      'field_of_study': fieldOfStudy,
      'is_current': isCurrent,
      'description': description,
      'source': source,
      'start_date': startDate,
      'end_date': endDate,
      'grade': grade,
    };
  }

  /// Strict parser for POST/PATCH mutation responses.
  ///
  /// Returns null when the payload is not a complete record: a missing
  /// or invalid `id`, or a missing/blank `institution` (required on
  /// create, so always present in a complete object). Callers must treat
  /// null as "mutation accepted but payload unusable" and refresh from
  /// GET instead of replacing list data with defaults.
  static EducationModel? tryParseMutation(Map<String, dynamic> json) {
    final id = JsonParsing.parseId(json['id']) ?? 0;
    if (id <= 0) return null;

    final institution =
        (json['institution'] ??
                json['school'] ??
                json['university'] ??
                json['university_name'])
            ?.toString()
            .trim() ??
        '';
    if (institution.isEmpty) return null;

    return EducationModel.fromJson(json);
  }
}
