import 'package:MatchIn/features/jobsAndApplications/data/data_sources/jobs_remote_data_source.dart';
import 'package:MatchIn/features/jobsAndApplications/domain/entities/job_entity.dart';

// TODO: استبدال الكلاس ده بـ JobsRemoteDataSourceImpl حقيقي يستخدم ApiConsumer
// لما تجهز endpoints الباك إند (نفس نمط Auth و Chatbot الحاليين)
class JobsMockRemoteDataSourceImpl
    implements JobsRemoteDataSource {
  final List<JobEntity> _dummyJobs = [
    JobEntity(
      id: '1',
      title: 'Junior Flutter Developer',
      companyName: 'TechNova',
      location: 'Cairo',
      workMode: 'Hybrid',
      experienceLevel: '0–2 years',
      employmentType: 'Full-time',
      postedDate: DateTime.now().subtract(
        const Duration(hours: 2),
      ),
      skills: const ['Flutter', 'REST API', 'Bloc'],
      matchPercentage: 92,
    ),
    JobEntity(
      id: '2',
      title: 'Mobile Developer Intern',
      companyName: 'CodeHub',
      location: 'Remote',
      workMode: 'Remote',
      experienceLevel: '0–1 years',
      employmentType: 'Internship',
      postedDate: DateTime.now(),
      skills: const ['Flutter', 'Firebase', 'Git'],
      matchPercentage: 82,
    ),
    JobEntity(
      id: '3',
      title: 'Flutter UI Engineer',
      companyName: 'AppStudio',
      location: 'Giza',
      workMode: 'On-site',
      experienceLevel: 'Mid Level',
      employmentType: 'Full-time',
      postedDate: DateTime.now().subtract(
        const Duration(days: 1),
      ),
      skills: const ['Dart', 'Flutter'],
      matchPercentage: 75,
    ),
  ];

  @override
  Future<List<JobEntity>> getJobs() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return List.unmodifiable(_dummyJobs);
  }

  @override
  Future<JobEntity> toggleSaveJob(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _dummyJobs.indexWhere(
      (job) => job.id == jobId,
    );
    if (index == -1) {
      throw Exception('Job not found');
    }

    final updated = _dummyJobs[index].copyWith(
      isSaved: !_dummyJobs[index].isSaved,
    );
    _dummyJobs[index] = updated;
    return updated;
  }

  @override
  Future<JobEntity> applyForJob(String jobId) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _dummyJobs.indexWhere(
      (job) => job.id == jobId,
    );
    if (index == -1) {
      throw Exception('Job not found');
    }

    final updated = _dummyJobs[index].copyWith(
      applicationStatus: JobApplicationStatus.pending,
    );
    _dummyJobs[index] = updated;
    return updated;
  }
}
