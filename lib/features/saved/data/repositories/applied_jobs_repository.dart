import 'package:flutter/material.dart';
import 'package:MatchIn/features/saved/presentation/models/applied_job_ui_model.dart';
import 'package:MatchIn/features/saved/presentation/models/saved_job_item_model.dart';

class AppliedJobsRepository {
  AppliedJobsRepository._() {
    _appliedJobs = List.from(AppliedJobUiModel.dummyAppliedJobs);
    appliedJobsNotifier = ValueNotifier<List<AppliedJobUiModel>>(
      List.unmodifiable(_appliedJobs),
    );
  }

  static final AppliedJobsRepository instance = AppliedJobsRepository._();

  late final List<AppliedJobUiModel> _appliedJobs;
  late final ValueNotifier<List<AppliedJobUiModel>> appliedJobsNotifier;

  List<AppliedJobUiModel> get appliedJobs => List.unmodifiable(_appliedJobs);

  void addApplication(AppliedJobUiModel job) {
    _appliedJobs.removeWhere((item) => item.id == job.id);
    _appliedJobs.insert(0, job);
    appliedJobsNotifier.value = List.unmodifiable(_appliedJobs);
  }

  void applyToSavedJob(SavedJobItemModel job) {
    final initials = _getInitials(job.company);
    final appliedJob = AppliedJobUiModel(
      id: 'app_${job.id}',
      title: job.title,
      company: job.company,
      companyInitials: initials,
      logoBgColor: const Color(0xFFE8F5E9),
      logoTextColor: const Color(0xFF2E7D32),
      tags: [job.location, job.workMode, job.jobType],
      appliedTime: 'Applied just now',
      footerStatus: 'Application submitted successfully',
      status: ApplicationStatus.applied,
    );
    addApplication(appliedJob);
  }

  String _getInitials(String company) {
    final words = company.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      final w = words.first;
      return w.substring(0, w.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}
