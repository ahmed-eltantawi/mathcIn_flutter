import 'package:equatable/equatable.dart';

/// Input for AI roadmap generation.
///
/// Only confirmed fields are sent. `target_type` is fixed to the sole
/// confirmed value `"role"` (no backend enum documented — do not add
/// alternatives without Swagger confirmation). `target_job_id` and
/// `job_post_id` appear in one Swagger example with unclear semantics
/// and are intentionally unsupported here.
///
/// TODO(roadmap-backend): confirm required fields, the `target_type`
/// enum, and job-id semantics against the authoritative Swagger.
class GenerateRoadmapParams extends Equatable {
  const GenerateRoadmapParams({this.targetRole, this.notes});

  /// Fixed to the only confirmed machine value. Not exposed in UI.
  static const String targetType = 'role';

  final String? targetRole;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'target_type': targetType,
      if (targetRole != null) 'target_role': targetRole,
      if (notes != null) 'notes': notes,
    };
  }

  @override
  List<Object?> get props => [targetRole, notes];
}
