import 'package:MatchIn/features/profile/domain/entities/add_candidate_project_params.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_project_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_candidate_project_params.dart';
import 'package:MatchIn/features/profile/presentation/cubits/projects_cubit.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_projects_widgets/add_project_details_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProjectForm extends StatefulWidget {
  const ProjectForm({this.project, super.key});

  final CandidateProjectEntity? project;

  bool get isEditing => project != null;

  @override
  State<ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends State<ProjectForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _technologyController;
  late final TextEditingController _projectUrlController;
  late final TextEditingController _githubUrlController;
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;

  late final ValueNotifier<List<String>> _technologies;

  @override
  void initState() {
    super.initState();

    final project = widget.project;

    _nameController = TextEditingController(text: project?.name ?? '');

    _descriptionController = TextEditingController(
      text: project?.description ?? '',
    );

    _technologyController = TextEditingController();

    _projectUrlController = TextEditingController(
      text: project?.projectUrl ?? '',
    );

    _githubUrlController = TextEditingController(
      text: project?.githubUrl ?? '',
    );

    _startDateController = TextEditingController(
      text: project?.startDate ?? '',
    );

    _endDateController = TextEditingController(text: project?.endDate ?? '');

    _technologies = ValueNotifier<List<String>>(
      List<String>.from(project?.technologies ?? const <String>[]),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _technologyController.dispose();
    _projectUrlController.dispose();
    _githubUrlController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _technologies.dispose();

    super.dispose();
  }

  void _addTechnology() {
    final technology = _technologyController.text.trim();

    if (technology.isEmpty) {
      return;
    }

    final alreadyExists = _technologies.value.any(
      (item) => item.toLowerCase() == technology.toLowerCase(),
    );

    if (alreadyExists) {
      return;
    }

    _technologies.value = [..._technologies.value, technology];

    _technologyController.clear();
  }

  void _removeTechnology(String technology) {
    _technologies.value = _technologies.value
        .where((item) => item != technology)
        .toList();
  }

  void _save() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      return;
    }

    final project = widget.project;

    if (project == null) {
      _addProject(name);
      return;
    }

    _updateProject(projectId: project.id, name: name);
  }

  void _addProject(String name) {
    context.read<ProjectsCubit>().addProject(
      AddCandidateProjectParams(
        name: name,
        description: _nullableText(_descriptionController),
        technologies: _technologies.value,
        projectUrl: _nullableText(_projectUrlController),
        githubUrl: _nullableText(_githubUrlController),
        startDate: _nullableText(_startDateController),
        endDate: _nullableText(_endDateController),
      ),
    );
  }

  void _updateProject({required int projectId, required String name}) {
    context.read<ProjectsCubit>().updateProject(
      UpdateCandidateProjectParams(
        projectId: projectId,
        name: name,
        description: _nullableText(_descriptionController),
        technologies: _technologies.value,
        projectUrl: _nullableText(_projectUrlController),
        githubUrl: _nullableText(_githubUrlController),
        startDate: _nullableText(_startDateController),
        endDate: _nullableText(_endDateController),
      ),
    );
  }

  String? _nullableText(TextEditingController controller) {
    final value = controller.text.trim();

    return value.isEmpty ? null : value;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: _technologies,
      builder: (context, technologies, _) {
        return AddProjectDetailsCard(
          nameController: _nameController,
          descriptionController: _descriptionController,
          technologyController: _technologyController,
          projectUrlController: _projectUrlController,
          githubUrlController: _githubUrlController,
          startDateController: _startDateController,
          endDateController: _endDateController,
          technologies: technologies,
          onAddTechnology: _addTechnology,
          onRemoveTechnology: _removeTechnology,
          onSave: _save,
          isEditing: widget.isEditing,
          onCancel: () {
            context.read<ProjectsCubit>().closeForm();
          },
        );
      },
    );
  }
}
