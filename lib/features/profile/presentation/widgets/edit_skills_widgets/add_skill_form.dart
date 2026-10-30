import 'package:MatchIn/features/profile/domain/entities/skill_search_result_entity.dart';
import 'package:MatchIn/features/profile/presentation/cubits/skills_cubit/skills_cubit.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/add_skill_section.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/skill_search_debouncer.dart';
import 'package:MatchIn/generated/l10n.dart';
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
      _debouncer.cancel();
      context.read<SkillsCubit>().clearSearch();
      return;
    }

    _debouncer.run(() {
      if (!mounted) return;

      context.read<SkillsCubit>().searchSkills(query);
    });
  }

  Future<void> _addSkill(SkillSearchResultEntity skill) async {
    final added = await context.read<SkillsCubit>().addSkill(
      skillId: skill.id,
      name: skill.name,
    );
    if (!mounted || !added) return;

    _controller.clear();
    context.read<SkillsCubit>().clearSearch();
  }

  void _addExactSuggestion() {
    final query = _controller.text.trim().toLowerCase();
    if (query.isEmpty) return;

    for (final skill in widget.suggestions) {
      if (skill.name.trim().toLowerCase() == query) {
        _addSkill(skill);
        return;
      }
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(S.of(context).selectSkillSuggestion)),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AddSkillSection(
      controller: _controller,
      suggestions: widget.suggestions,
      onSearchChanged: _onSearchChanged,
      onAddPressed: _addExactSuggestion,
      onSuggestionPressed: (skill) {
        _controller.text = skill.name;

        _controller.selection = TextSelection.collapsed(
          offset: skill.name.length,
        );

        _addSkill(skill);
      },
      onSubmitted: (_) => _onSearchChanged(_controller.text),
    );
  }
}
