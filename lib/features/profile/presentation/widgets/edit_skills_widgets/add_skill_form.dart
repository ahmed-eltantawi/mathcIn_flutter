import 'package:MatchIn/features/profile/presentation/cubits/skills_cubit.dart';
import 'package:MatchIn/features/profile/presentation/widgets/edit_skills_widgets/add_skill_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddSkillForm extends StatefulWidget {
  const AddSkillForm({required this.suggestions, super.key});

  final List<String> suggestions;

  @override
  State<AddSkillForm> createState() => _AddSkillFormState();
}

class _AddSkillFormState extends State<AddSkillForm> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addSkill(String name) {
    final value = name.trim();

    if (value.isEmpty) {
      return;
    }

    context.read<SkillsCubit>().addSkill(name: value);
  }

  @override
  Widget build(BuildContext context) {
    return AddSkillSection(
      controller: _controller,
      suggestions: widget.suggestions,
      onAddPressed: () {
        _addSkill(_controller.text);
      },
      onSuggestionPressed: (skill) {
        _controller.text = skill;
        _addSkill(skill);
      },
    );
  }
}
