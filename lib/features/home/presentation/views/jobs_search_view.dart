import 'package:MatchIn/features/home/presentation/widgets/jobs_search_view_widgets/jobs_search_view_body.dart';
import 'package:flutter/material.dart';

class JobsSearchView extends StatelessWidget {
  const JobsSearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(child: JobsSearchViewBody()),
    );
  }
}
