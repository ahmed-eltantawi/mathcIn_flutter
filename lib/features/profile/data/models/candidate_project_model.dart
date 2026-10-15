import 'package:MatchIn/features/profile/data/models/json_parsing.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_project_entity.dart';

class CandidateProjectModel extends CandidateProjectEntity {
  const CandidateProjectModel({
    required super.id,
    required super.name,
    required super.technologies,
    required super.source,
    super.description,
    super.projectUrl,
    super.githubUrl,
    super.startDate,
    super.endDate,
  });

  factory CandidateProjectModel.fromJson(Map<String, dynamic> json) {
    return CandidateProjectModel(
      id: JsonParsing.parseId(json['id']) ?? 0,
      name: JsonParsing.parseString(json['name']) ?? '',
      description: JsonParsing.parseString(json['description']),
      technologies: JsonParsing.parseStringList(json['technologies']),
      projectUrl: JsonParsing.parseString(json['project_url']),
      githubUrl: JsonParsing.parseString(json['github_url']),
      source: JsonParsing.parseString(json['source']) ?? 'manual',
      startDate: JsonParsing.parseString(json['start_date']),
      endDate: JsonParsing.parseString(json['end_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'technologies': technologies,
      'project_url': projectUrl,
      'github_url': githubUrl,
      'source': source,
      'start_date': startDate,
      'end_date': endDate,
    };
  }

  /// Strict parser for POST/PATCH mutation responses.
  ///
  /// Returns null when the payload is not a complete record: an
  /// invalid `id` or a blank `name` (required on create, so always
  /// present in a complete object). Callers must treat null as
  /// "mutation accepted but payload unusable" and refresh from GET
  /// instead of replacing list data with defaults.
  static CandidateProjectModel? tryParseMutation(Map<String, dynamic> json) {
    final id = JsonParsing.parseId(json['id']) ?? 0;
    if (id <= 0) return null;

    final name = JsonParsing.parseString(json['name'])?.trim() ?? '';
    if (name.isEmpty) return null;

    return CandidateProjectModel.fromJson(json);
  }
}
