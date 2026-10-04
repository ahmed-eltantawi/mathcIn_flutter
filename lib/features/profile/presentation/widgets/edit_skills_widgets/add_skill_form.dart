import 'package:MatchIn/features/profile/domain/entities/skill_search_result_entity.dart';
import 'package:MatchIn/features/profile/presentation/cubits/skills_cubit.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/add_skill_section.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/skill_search_debouncer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddSkillForm extends StatefulWidget {
  const AddSkillForm({required this.suggestions, super.key});

  final List<SkillSearchResultEntity> suggestions;

  @override
  State<AddSkillForm> createState() => _AddSkillFormState();
}

class _AddSkillFormState extends State<AddSkillForm> {
  late final TextEditingController _controller;
  late final SkillSearchDebouncer _debouncer;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
    _debouncer = SkillSearchDebouncer();
  }

  @override
  void dispose() {
    _controller.dispose();
    _debouncer.dispose();

    super.dispose();
  }

  void _onSearchChanged(String value) {
    final query = value.trim();

    if (query.isEmpty) {
      _debouncer.dispose();
      context.read<SkillsCubit>().clearSearch();
      return;
    }

    _debouncer.run(() {
      if (!mounted) return;

      context.read<SkillsCubit>().searchSkills(query);
    });
  }

  void _addSkill(String value) {
    final name = value.trim();

    if (name.isEmpty) return;

    context.read<SkillsCubit>().addSkill(name: name);
  }

  @override
  Widget build(BuildContext context) {
    return AddSkillSection(
      controller: _controller,
      suggestions: widget.suggestions.map((skill) => skill.name).toList(),
      onSearchChanged: _onSearchChanged,
      onAddPressed: () {
        _addSkill(_controller.text);
      },
      onSuggestionPressed: (skill) {
        _controller.text = skill;

        _controller.selection = TextSelection.collapsed(offset: skill.length);

        _addSkill(skill);
      },
    );
  }
}
