import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/features/home/presentation/cubit/home_cubit.dart';
import 'package:MatchIn/features/home/presentation/cubit/home_state.dart';
import 'package:MatchIn/features/home/presentation/widgets/home_view_widgets/home_card_view_matches_jobs.dart';
import 'package:MatchIn/features/home/presentation/widgets/home_view_widgets/home_header.dart';
import 'package:MatchIn/features/home/presentation/widgets/home_view_widgets/home_search_field.dart';
import 'package:MatchIn/features/home/presentation/widgets/home_view_widgets/home_indicator_header.dart';
import 'package:MatchIn/features/home/presentation/widgets/home_view_widgets/recommended_jobs_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: 12.h),

        BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            return switch (state) {
              HomeInitial() ||
              HomeLoading() => const HomeInicatorHeader(),
              HomeError(:final message) => Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                ),
                child: Text(message),
              ),
              HomeLoaded(:final dashboard) => HomeHeader(
                userName: dashboard.userName,
              ),
            };
          },
        ),

        SizedBox(height: 20.h),

        HomeSearchField(
          onTap: () =>
              context.push(AppRoutes.kJobsSearchView),
        ),

        SizedBox(height: 16.h),

        BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is! HomeLoaded)
              return const SizedBox.shrink();
            return HomeCardViewMatchesJobs(
              matchesCount: state.dashboard.matchesCount,
            );
          },
        ),

        SizedBox(height: 12.h),

        const RecommendedJobsSection(),

        SizedBox(height: 12.h),
      ],
    );
  }
}
