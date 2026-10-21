import 'package:MatchIn/features/profile/domain/entities/cv_extraction_entity.dart';
import 'package:equatable/equatable.dart';

/// Verification submission for `POST /cv/extractions/{extraction}/verify`.
///
/// Follows the documented schema exactly: `action` plus the verified
/// collections. Only non-empty items are serialized; user edits are
/// validated by the caller before submission.
class CvVerifyParams extends Equatable {
  const CvVerifyParams({
    required this.extractionId,
    this.action = 'confirm',
    this.skills = const [],
    this.educations = const [],
    this.experiences = const [],
  });

  final dynamic extractionId;
  final String action;
  final List<CvExtractedItem> skills;
  final List<CvExtractedItem> educations;
  final List<CvExtractedItem> experiences;

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'verified_skills': skills
          .map((item) => item.toVerifyJson())
          .where((json) => json.isNotEmpty)
          .toList(),
      'verified_educations': educations
          .map((item) => item.toVerifyJson())
          .where((json) => json.isNotEmpty)
          .toList(),
      'verified_experiences': experiences
          .map((item) => item.toVerifyJson())
          .where((json) => json.isNotEmpty)
          .toList(),
    };
  }

  @override
  List<Object?> get props => [
    extractionId,
    action,
    skills,
    educations,
    experiences,
  ];
}
