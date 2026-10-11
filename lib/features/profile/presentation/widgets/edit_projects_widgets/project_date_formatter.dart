import 'package:MatchIn/features/profile/domain/entities/candidate_project_entity.dart';

abstract class ProjectDateFormatter {
  static String format(CandidateProjectEntity project) {
    final start = project.startDate;
    final end = project.endDate;

    if (start == null && end == null) {
      return '';
    }

    if (start != null && end == null) {
      return start;
    }

    if (start == null) {
      return end ?? '';
    }

    return '$start – $end';
  }
}
