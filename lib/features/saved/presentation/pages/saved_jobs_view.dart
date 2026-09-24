import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/core/utils/app_colors.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/widgets/job_details_widgets/job_card_widgets/job_card.dart';
import 'package:MatchIn/features/saved/data/repositories/applied_jobs_repository.dart';
import 'package:MatchIn/features/saved/domain/entities/saved_job_entity.dart';
import 'package:MatchIn/features/saved/presentation/cubit/saved_jobs_cubit.dart';
import 'package:MatchIn/features/saved/presentation/cubit/saved_jobs_state.dart';
import 'package:MatchIn/features/saved/presentation/models/applied_job_ui_model.dart';
import 'package:MatchIn/features/saved/presentation/models/saved_tab_type.dart';
import 'package:MatchIn/features/saved/presentation/widgets/applied_job_card.dart';
import 'package:MatchIn/features/saved/presentation/widgets/saved_segmented_tab.dart';
import 'package:MatchIn/features/saved/presentation/widgets/saved_summary_bar.dart';
import 'package:MatchIn/features/saved/presentation/widgets/saved_top_bar.dart';

class SavedJobsView extends StatelessWidget {
  const SavedJobsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SavedJobsCubit>(
      create: (_) => getIt<SavedJobsCubit>()..fetchSavedJobs(),
      child: const _SavedJobsContent(),
    );
  }
}

class _SavedJobsContent extends StatefulWidget {
  const _SavedJobsContent();

  @override
  State<_SavedJobsContent> createState() => _SavedJobsContentState();
}

class _SavedJobsContentState extends State<_SavedJobsContent> {
  SavedTabType _activeTab = SavedTabType.saved;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<SavedJobsCubit>().loadMoreSavedJobs();
    }
  }

  void _onTabChanged(SavedTabType tab) {
    if (_activeTab != tab) {
      setState(() {
        _activeTab = tab;
      });
    }
  }

  void _onApplyToJob(SavedJobEntity job) {
    // Record application in repository so it appears in Applied tab
    AppliedJobsRepository.instance.addApplication(
      AppliedJobUiModel(
        id: 'app_${job.id}',
        title: job.title,
        company: job.company,
        companyInitials: _getInitials(job.company),
        logoBgColor: const Color(0xFFE8F5E9),
        logoTextColor: const Color(0xFF2E7D32),
        tags: [job.location, job.workMode, job.jobType],
        appliedTime: 'Applied just now',
        footerStatus: 'Application submitted successfully',
        status: ApplicationStatus.applied,
      ),
    );
    // Navigate to apply flow
    context.push(AppRoutes.kapplyForRole);
  }

  String _getInitials(String company) {
    final words =
        company.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) {
      final w = words.first;
      return w.substring(0, w.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isSavedTab = _activeTab == SavedTabType.saved;

    return ValueListenableBuilder<List<AppliedJobUiModel>>(
      valueListenable: AppliedJobsRepository.instance.appliedJobsNotifier,
      builder: (context, appliedJobs, _) {
        return BlocBuilder<SavedJobsCubit, SavedJobsState>(
          builder: (context, savedState) {
            int savedCount = 0;
            if (savedState is SavedJobsLoaded) {
              savedCount = savedState.jobs.length;
            }

            return Scaffold(
              backgroundColor: AppColors.background,
              body: SafeArea(
                child: Column(
                  children: [
                    // Top App Bar
                    SavedTopBar(
                      title: isSavedTab ? 'Saved Jobs' : 'Applications',
                      onSearchTap: () {
                        context.push(AppRoutes.kJobsSearchView);
                      },
                    ),

                    // Segmented Tab Selector (Saved / Applied)
                    SavedSegmentedTab(
                      activeTab: _activeTab,
                      onTabChanged: _onTabChanged,
                    ),

                    // Summary Bar
                    SavedSummaryBar(
                      countText: isSavedTab
                          ? '$savedCount saved opportunities'
                          : '${appliedJobs.length} applications',
                      actionLabel:
                          isSavedTab ? 'Recently saved' : 'All statuses',
                      actionIcon:
                          isSavedTab ? Icons.sort : Icons.filter_list,
                      onActionTap: () {
                        // Future sort/filter integration
                      },
                    ),

                    // List Content
                    Expanded(
                      child: isSavedTab
                          ? _buildSavedJobsList(savedState)
                          : _buildAppliedJobsList(appliedJobs),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSavedJobsList(SavedJobsState state) {
    if (state is SavedJobsLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is SavedJobsError) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48.sp,
                color: Colors.redAccent,
              ),
              SizedBox(height: 12.h),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: () {
                  context.read<SavedJobsCubit>().fetchSavedJobs();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state is SavedJobsLoaded) {
      if (state.jobs.isEmpty) {
        return RefreshIndicator(
          onRefresh: () =>
              context.read<SavedJobsCubit>().fetchSavedJobs(isRefresh: true),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: 120.h),
              Center(
                child: Text(
                  'No saved jobs yet',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () =>
            context.read<SavedJobsCubit>().fetchSavedJobs(isRefresh: true),
        child: AnimationLimiter(
          child: ListView.separated(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
            itemCount: state.jobs.length + (state.isLoadingMore ? 1 : 0),
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              if (index == state.jobs.length) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const Center(child: CircularProgressIndicator()),
                );
              }

              final job = state.jobs[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: JobCard(
                      job: job.toJobEntity(),
                      showShareButton: true,
                      onSave: () {
                        context.read<SavedJobsCubit>().toggleBookmark(job);
                      },
                      onApply: () => _onApplyToJob(job),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildAppliedJobsList(List<AppliedJobUiModel> appliedJobs) {
    if (appliedJobs.isEmpty) {
      return Center(
        child: Text(
          'No applications yet',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return AnimationLimiter(
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
        itemCount: appliedJobs.length,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final application = appliedJobs[index];
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: AppliedJobCard(
                  application: application,
                  onCardTap: () {
                    context.push(AppRoutes.ktrackingApplication);
                  },
                  onViewApplicationTap: () {
                    context.push(AppRoutes.ktrackingApplication);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
