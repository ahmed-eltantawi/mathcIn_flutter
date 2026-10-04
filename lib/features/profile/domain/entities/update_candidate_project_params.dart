import 'package:equatable/equatable.dart';

class UpdateCandidateProjectParams extends Equatable {
  const UpdateCandidateProjectParams({
    required this.projectId,
    this.name,
    this.description,
    this.technologies,
    this.projectUrl,
    this.githubUrl,
    this.startDate,
    this.endDate,
  });

  final int projectId;
  final String? name;
  final String? description;
  final List<String>? technologies;
  final String? projectUrl;
  final String? githubUrl;
  final String? startDate;
  final String? endDate;

  @override
  List<Object?> get props => [
    projectId,
    name,
    description,
    technologies,
    projectUrl,
    githubUrl,
    startDate,
    endDate,
  ];
}
