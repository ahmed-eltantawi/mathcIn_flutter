import 'package:MatchIn/features/profile/presentation/widgets/edit_education_widgets/edit_education_view_body.dart';
import 'package:flutter/material.dart';

class EditEducationView extends StatelessWidget {
  const EditEducationView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: EditEducationViewBody()),
    );
  }
}
