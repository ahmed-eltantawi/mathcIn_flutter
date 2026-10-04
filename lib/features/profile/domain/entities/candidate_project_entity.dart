import 'package:equatable/equatable.dart';

class CandidateProjectEntity extends Equatable {
  const CandidateProjectEntity({
    required this.id,
    required this.name,
    required this.technologies,
    required this.source,
    this.description,
    this.projectUrl,
    this.githubUrl,
    this.startDate,
    this.endDate,
  });

  final int id;
  final String name;
  final String? description;
  final List<String> technologies;
  final String? projectUrl;
  final String? githubUrl;
  final String source;
  final String? startDate;
  final String? endDate;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    technologies,
    projectUrl,
    githubUrl,
    source,
    startDate,
    endDate,
  ];
}
