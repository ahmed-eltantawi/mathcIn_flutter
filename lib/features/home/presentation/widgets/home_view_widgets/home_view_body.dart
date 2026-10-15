import 'package:MatchIn/core/extensions/snack_bar_extensions.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/widgets/error/app_error.dart';
import 'package:MatchIn/features/home/presentation/cubit/home_cubit.dart';
import 'package:MatchIn/features/home/presentation/cubit/home_state.dart';
import 'package:MatchIn/features/home/presentation/widgets/home_view_widgets/home_card_view_matches_jobs.dart';
import 'package:MatchIn/features/home/presentation/widgets/home_view_widgets/home_header.dart';
import 'package:MatchIn/features/home/presentation/widgets/home_view_widgets/home_search_field.dart';
import 'package:MatchIn/features/home/presentation/widgets/home_view_widgets/home_header_skeleton.dart';
import 'package:MatchIn/features/home/presentation/widgets/home_view_widgets/recommended_jobs_section.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_cubit.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/jobs_feed_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  //! ===== Pull-to-refresh =====
  // --- Refreshes only jobs-related data: the dashboard header (matches
  // --- count derives from the jobs endpoint) and the recommended jobs feed.
  // --- Both cubits guard against overlapping requests internally, and both
  // --- preserve cached content on failure, so the indicator simply awaits
  // --- the combined future and cached jobs stay visible on errors.
  Future<void> _handleRefresh(BuildContext context) {
    return Future.wait([
      context.read<HomeCubit>().getHomeDashboard(),
      context.read<JobsFeedCubit>().refreshJobs(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<JobsFeedCubit, JobsFeedState>(
      // --- Show one snackbar per distinct refresh failure; cached jobs stay on screen ---
      listenWhen: (previous, current) {
        if (current is! JobsFeedLoaded) return false;
        final message = current.errorMessage;
        if (message == null || message.isEmpty) return false;
        final previousMessage = previous is JobsFeedLoaded
            ? previous.errorMessage
            : null;
        return message != previousMessage;
      },
      listener: (context, state) {
        context.showErrorSnackBar((state as JobsFeedLoaded).errorMessage!);
      },
      child: RefreshIndicator(
        onRefresh: () => _handleRefresh(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: 12.h),

            BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                return switch (state) {
                  HomeInitial() ||
                  HomeLoading() => const HomeHeaderSkeleton(),
                  HomeError(:final message) => AppErrorWidget(
                    message: message,
                    onRetry: () =>
                        context.read<HomeCubit>().getHomeDashboard(),
                  ),
                  HomeLoaded(:final dashboard) => HomeHeader(
                    userName: dashboard.userName,
                  ),
                };
              },
            ),

            SizedBox(height: 20.h),

            HomeSearchField(
              onTap: () => context.push(AppRoutes.kJobsSearchView),
            ),

            SizedBox(height: 16.h),

            BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state is! HomeLoaded) {
                  return const SizedBox.shrink();
                }
                return HomeCardViewMatchesJobs(
                  matchesCount: state.dashboard.matchesCount,
                  onViewMatches: () =>
                      context.push(AppRoutes.kJobsSearchView),
                );
              },
            ),

            SizedBox(height: 12.h),

            const RecommendedJobsSection(),

            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }
}
