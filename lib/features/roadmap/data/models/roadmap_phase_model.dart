import 'package:MatchIn/features/roadmap/data/models/roadmap_milestone_model.dart';

/// One generation phase (`data.phases[]`): an ordered group of milestones.
///
/// The backend generation response nests milestones inside phases instead
/// of exposing a flat milestone list. Phases carry their own ordering and
/// status; tasks always live under `milestones[].tasks[]`.
class RoadmapPhaseModel {
  const RoadmapPhaseModel({
    required this.id,
    required this.title,
    this.description,
    required this.order,
    this.status,
    this.milestones = const [],
  });

  factory RoadmapPhaseModel.fromJson(Map<String, dynamic> json) {
    final milestonesJson = json['milestones'];
    final List<RoadmapMilestoneModel> milestones = [];
    if (milestonesJson is List) {
      for (final entry in milestonesJson) {
        if (entry is! Map<String, dynamic>) continue;
        try {
          milestones.add(RoadmapMilestoneModel.fromJson(entry));
        } catch (_) {
          continue;
        }
      }
    }
    return RoadmapPhaseModel(
      id: _parseId(json['id']) ?? 0,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      order: _parseOrder(json['order']),
      status: json['status']?.toString(),
      milestones: milestones,
    );
  }

  final int id;
  final String title;
  final String? description;
  final int order;
  final String? status;
  final List<RoadmapMilestoneModel> milestones;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      if (description != null) 'description': description,
      'order': order,
      if (status != null) 'status': status,
      'milestones': milestones.map((m) => m.toJson()).toList(),
    };
  }

  static int? _parseId(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static int _parseOrder(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) {
      final asInt = int.tryParse(value.trim());
      if (asInt != null) return asInt;
      final asDouble = double.tryParse(value.trim());
      if (asDouble != null) return asDouble.toInt();
    }
    return 0;
  }
}
