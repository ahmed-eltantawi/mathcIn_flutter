import 'package:equatable/equatable.dart';

class UpdateCandidateProjectParams extends Equatable {
  const UpdateCandidateProjectParams({
    required this.projectId,
    this.name = _unset,
    this.description = _unset,
    this.technologies = _unset,
    this.projectUrl = _unset,
    this.githubUrl = _unset,
    this.startDate = _unset,
    this.endDate = _unset,
  });

  /// Sentinel marking a field as omitted from PATCH.
  /// `_unset` means "unchanged, do not send".
  /// An explicit `null` means "clear this field".
  /// A value means "update to this value".
  final int projectId;
  final Object? name;
  final Object? description;
  final Object? technologies;
  final Object? projectUrl;
  final Object? githubUrl;
  final Object? startDate;
  final Object? endDate;

  static const Object _unset = Object();

  static const Object unset = _unset;

  static bool isSet(Object? value) => !identical(value, _unset);

  bool get hasChanges =>
      isSet(name) ||
      isSet(description) ||
      isSet(technologies) ||
      isSet(projectUrl) ||
      isSet(githubUrl) ||
      isSet(startDate) ||
      isSet(endDate);

  UpdateCandidateProjectParams copyWith({
    required int projectId,
    Object? name = _unset,
    Object? description = _unset,
    Object? technologies = _unset,
    Object? projectUrl = _unset,
    Object? githubUrl = _unset,
    Object? startDate = _unset,
    Object? endDate = _unset,
  }) {
    return UpdateCandidateProjectParams(
      projectId: projectId,
      name: identical(name, _unset) ? this.name : name,
      description: identical(description, _unset)
          ? this.description
          : description,
      technologies: identical(technologies, _unset)
          ? this.technologies
          : technologies,
      projectUrl: identical(projectUrl, _unset) ? this.projectUrl : projectUrl,
      githubUrl: identical(githubUrl, _unset) ? this.githubUrl : githubUrl,
      startDate: identical(startDate, _unset) ? this.startDate : startDate,
      endDate: identical(endDate, _unset) ? this.endDate : endDate,
    );
  }

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
