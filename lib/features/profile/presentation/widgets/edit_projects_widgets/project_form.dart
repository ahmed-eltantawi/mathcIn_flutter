import 'package:MatchIn/features/profile/domain/entities/add_candidate_project_params.dart';
import 'package:MatchIn/features/profile/domain/entities/candidate_project_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/update_candidate_project_params.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_projects_widgets/add_project_details_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/profile_form_validator.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';

class ProjectForm extends StatefulWidget {
  const ProjectForm({
    this.project,
    this.isSaving = false,
    required this.onAdd,
    required this.onUpdate,
    required this.onCancel,
    super.key,
  });

  final CandidateProjectEntity? project;
  final bool isSaving;
  final ValueChanged<AddCandidateProjectParams> onAdd;
  final ValueChanged<UpdateCandidateProjectParams> onUpdate;
  final VoidCallback onCancel;

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
  late final ValueNotifier<DateTime?> _startDate;
  late final ValueNotifier<DateTime?> _endDate;

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
    _startDate = ValueNotifier<DateTime?>(
      ProfileFormValidator.parseDate(project?.startDate),
    );
    _endDate = ValueNotifier<DateTime?>(
      ProfileFormValidator.parseDate(project?.endDate),
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
    _startDate.dispose();
    _endDate.dispose();

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

  Future<void> _pickDate({
    required ValueNotifier<DateTime?> notifier,
    required TextEditingController controller,
  }) async {
    if (widget.isSaving) return;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: notifier.value ?? now,
      firstDate: DateTime(1950),
      lastDate: DateTime(now.year + 10, 12, 31),
    );
    if (picked == null) return;
    notifier.value = DateTime(picked.year, picked.month, picked.day);
    controller.text = ProfileFormValidator.formatDate(notifier.value!);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  static String? _normalizedOrNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static bool _sameTechnologies(List<String> current, List<String> baseline) {
    if (current.length != baseline.length) return false;
    for (int i = 0; i < current.length; i++) {
      if (current[i] != baseline[i]) return false;
    }
    return true;
  }

  void _save() {
    if (widget.isSaving) return;
    final locale = S.of(context);

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showMessage(locale.required);
      return;
    }

    final start = _startDate.value;
    final end = _endDate.value;

    final rangeError = ProfileFormValidator.validateDateRange(
      start: start,
      end: end,
      invalidMessage: locale.invalidDateRange,
    );
    if (rangeError != null) {
      _showMessage(rangeError);
      return;
    }

    final project = widget.project;
    if (project == null) {
      _addProject(name: name, start: start, end: end);
      return;
    }

    _updateProject(project: project, name: name, start: start, end: end);
  }

  void _addProject({
    required String name,
    required DateTime? start,
    required DateTime? end,
  }) {
    widget.onAdd(
      AddCandidateProjectParams(
        name: name,
        description: _normalizedOrNull(_descriptionController.text),
        technologies: _technologies.value,
        projectUrl: _normalizedOrNull(_projectUrlController.text),
        githubUrl: _normalizedOrNull(_githubUrlController.text),
        startDate: start == null
            ? null
            : ProfileFormValidator.formatDate(start),
        endDate: end == null ? null : ProfileFormValidator.formatDate(end),
      ),
    );
  }

  void _updateProject({
    required CandidateProjectEntity project,
    required String name,
    required DateTime? start,
    required DateTime? end,
  }) {
    var params = UpdateCandidateProjectParams(projectId: project.id);

    if (name != project.name) {
      params = params.copyWith(projectId: project.id, name: name);
    }

    final description = _normalizedOrNull(_descriptionController.text);
    if (description != project.description) {
      params = params.copyWith(projectId: project.id, description: description);
    }

    if (!_sameTechnologies(_technologies.value, project.technologies)) {
      params = params.copyWith(
        projectId: project.id,
        technologies: _technologies.value,
      );
    }

    final projectUrl = _normalizedOrNull(_projectUrlController.text);
    if (projectUrl != project.projectUrl) {
      params = params.copyWith(projectId: project.id, projectUrl: projectUrl);
    }

    final githubUrl = _normalizedOrNull(_githubUrlController.text);
    if (githubUrl != project.githubUrl) {
      params = params.copyWith(projectId: project.id, githubUrl: githubUrl);
    }

    final startText = start == null
        ? null
        : ProfileFormValidator.formatDate(start);
    if (startText != project.startDate) {
      params = params.copyWith(projectId: project.id, startDate: startText);
    }

    final endText = end == null ? null : ProfileFormValidator.formatDate(end);
    if (endText != project.endDate) {
      params = params.copyWith(projectId: project.id, endDate: endText);
    }

    if (!params.hasChanges) {
      widget.onCancel();
      return;
    }

    widget.onUpdate(params);
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
          isSaving: widget.isSaving,
          onStartDateTap: () =>
              _pickDate(notifier: _startDate, controller: _startDateController),
          onEndDateTap: () =>
              _pickDate(notifier: _endDate, controller: _endDateController),
          onCancel: widget.onCancel,
        );
      },
    );
  }
}
