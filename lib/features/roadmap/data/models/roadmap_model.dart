import 'package:MatchIn/features/roadmap/data/models/roadmap_milestone_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_phase_model.dart';
import 'package:MatchIn/features/roadmap/data/models/roadmap_task_model.dart';
import 'package:MatchIn/features/roadmap/domain/entities/roadmap_entity.dart';

class RoadmapModel extends RoadmapEntity {
  const RoadmapModel({
    required super.id,
    super.candidateId,
    super.targetRole,
    required super.title,
    super.description,
    super.status,
    super.completionPercentage,
    super.milestones,
    super.createdAt,
    this.phases = const [],
  });

  factory RoadmapModel.fromJson(Map<String, dynamic> json) {
    final phasesJson = json['phases'];
    final milestonesJson = json['milestones'];
    final tasksJson = json['tasks'];

    List<RoadmapPhaseModel> parsedPhases = const [];
    List<RoadmapMilestoneModel> parsedMilestones = const [];
    // --- One malformed entry must not discard the whole roadmap:
    // --- each entry is parsed independently and skipped on failure. ---
    if (phasesJson is List) {
      final List<RoadmapPhaseModel> phases = [];
      for (final entry in phasesJson) {
        if (entry is! Map<String, dynamic>) continue;
        try {
          phases.add(RoadmapPhaseModel.fromJson(entry));
        } catch (_) {
          continue;
        }
      }
      phases.sort((a, b) => a.order.compareTo(b.order));
      parsedPhases = phases;
      // --- Flatten phase milestones in (phase, milestone) order so no
      // --- task is lost when the backend groups by phase. Milestone
      // --- orders restart per phase on the backend, so they are
      // --- re-sequenced globally here: otherwise the view-layer sort
      // --- would interleave phases (e.g. phase 2/order 1 before phase
      // --- 1/order 2) and scramble the progression. ---
      final List<RoadmapMilestoneModel> flattened = [];
      var sequence = 0;
      for (final phase in phases) {
        final ordered = List<RoadmapMilestoneModel>.of(phase.milestones)
          ..sort((a, b) => a.order.compareTo(b.order));
        for (final milestone in ordered) {
          sequence++;
          flattened.add(
            milestone.order == sequence
                ? milestone
                : RoadmapMilestoneModel(
                    id: milestone.id,
                    roadmapId: milestone.roadmapId,
                    title: milestone.title,
                    order: sequence,
                    tasks: milestone.tasks,
                  ),
          );
        }
      }
      parsedMilestones = flattened;
    } else if (milestonesJson is List) {
      final List<RoadmapMilestoneModel> milestones = [];
      for (final entry in milestonesJson) {
        if (entry is! Map<String, dynamic>) continue;
        try {
          milestones.add(RoadmapMilestoneModel.fromJson(entry));
        } catch (_) {
          continue;
        }
      }
      parsedMilestones = milestones;
    } else if (milestonesJson is Map<String, dynamic>) {
      final List<RoadmapMilestoneModel> milestones = [];
      for (final entry in milestonesJson.values) {
        if (entry is! Map<String, dynamic>) continue;
        try {
          milestones.add(RoadmapMilestoneModel.fromJson(entry));
        } catch (_) {
          continue;
        }
      }
      parsedMilestones = milestones;
    } else if (tasksJson is List) {
      // If the backend returns flat tasks on data, wrap them in a default milestone
      final List<RoadmapTaskModel> tasks = tasksJson
          .whereType<Map<String, dynamic>>()
          .where((item) => _parseId(item['id']) != null)
          .map(RoadmapTaskModel.fromJson)
          .toList();
      if (tasks.isNotEmpty) {
        parsedMilestones = [
          RoadmapMilestoneModel(
            id: 1,
            roadmapId: _parseId(json['id']) ?? 0,
            title: json['title']?.toString() ?? 'Tasks',
            order: 1,
            tasks: tasks,
          ),
        ];
      }
    }

    final double completion =
        _parseDouble(json['progress']) ??
        (json['completion_percentage'] as num?)?.toDouble() ??
        double.tryParse(json['completion_percentage']?.toString() ?? '') ??
        0.0;

    return RoadmapModel(
      id: _parseId(json['id']) ?? 0,
      candidateId: _parseId(json['candidate_id']),
      targetRole: _parseTargetRole(json),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      status: json['status']?.toString(),
      completionPercentage: completion,
      milestones: parsedMilestones,
      createdAt: json['created_at']?.toString(),
      phases: parsedPhases,
    );
  }

  /// Generation phases (`data.phases[]`) when the backend nests
  /// milestones inside phases. The flattened [milestones] list stays
  /// the canonical ordered source for node mapping; phases are kept
  /// for fidelity and cache round-trips.
  final List<RoadmapPhaseModel> phases;

  /// Generation responses nest the role in `data.target.role`; older
  /// shapes expose a top-level `target_role` string. Both are honored.
  static String? _parseTargetRole(Map<String, dynamic> json) {
    final target = json['target'];
    if (target is Map<String, dynamic>) {
      final role = target['role'] ?? target['target_role'];
      if (role != null && role.toString().trim().isNotEmpty) {
        return role.toString().trim();
      }
    } else if (target is String && target.trim().isNotEmpty) {
      return target.trim();
    }
    final legacy = json['target_role'];
    if (legacy != null && legacy.toString().trim().isNotEmpty) {
      return legacy.toString().trim();
    }
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (candidateId != null) 'candidate_id': candidateId,
      if (targetRole != null) 'target_role': targetRole,
      if (targetRole != null) 'target': {'type': 'role', 'role': targetRole},
      'title': title,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      'completion_percentage': completionPercentage,
      'progress': completionPercentage,
      if (phases.isNotEmpty) 'phases': phases.map((p) => p.toJson()).toList(),
      'milestones': milestones.map((m) {
        if (m is RoadmapMilestoneModel) return m.toJson();
        return RoadmapMilestoneModel(
          id: m.id,
          roadmapId: m.roadmapId,
          title: m.title,
          order: m.order,
          tasks: m.tasks,
        ).toJson();
      }).toList(),
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  static int? _parseId(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }
}
