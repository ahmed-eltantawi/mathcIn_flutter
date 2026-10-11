import 'package:equatable/equatable.dart';

class AddCandidateProjectParams extends Equatable {
  const AddCandidateProjectParams({
    required this.name,
    this.description,
    this.technologies = const [],
    this.projectUrl,
    this.githubUrl,
    this.startDate,
    this.endDate,
  });

  final String name;
  final String? description;
  final List<String> technologies;
  final String? projectUrl;
  final String? githubUrl;
  final String? startDate;
  final String? endDate;

  @override
  List<Object?> get props => [
    name,
    description,
    technologies,
    projectUrl,
    githubUrl,
    startDate,
    endDate,
  ];
}
