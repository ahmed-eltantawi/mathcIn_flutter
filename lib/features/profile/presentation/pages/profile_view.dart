import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/core/widgets/error/app_error.dart';
import 'package:MatchIn/core/widgets/loading/app_loading.dart';
import 'package:MatchIn/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubit/profile_state.dart';
import 'package:MatchIn/features/profile/presentation/widgets/cards/education_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/cards/experience_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/cards/main_profile_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = S.of(context);

    return BlocProvider<ProfileCubit>(
      create: (_) => getIt<ProfileCubit>()..fetchUserProfile(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            locale.candidateProfile,
            style: theme.textTheme.titleLarge,
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              return switch (state) {
                ProfileInitial() || ProfileLoading() => const AppLoadingWidget(),
                ProfileError(:final message) => AppErrorWidget(
                    message: message,
                    onRetry: () =>
                        context.read<ProfileCubit>().fetchUserProfile(),
                  ),
                ProfileLoaded(:final userProfile) => RefreshIndicator(
                    onRefresh: () =>
                        context.read<ProfileCubit>().fetchUserProfile(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.all(16.w),
                      children: [
                        MainProfileCard(
                          name: userProfile.name,
                          jobTitle: userProfile.jobTitle,
                          location: userProfile.location,
                          avatarUrl: userProfile.avatarUrl,
                        ),
                        if (userProfile.universityName != null) ...[
                          SizedBox(height: 12.h),
                          EducationCard(
                            universityName: userProfile.universityName!,
                            degree: userProfile.degree ?? '',
                            years: userProfile.years ?? '',
                          ),
                        ],
                        if (userProfile.experienceJobTitle != null ||
                            userProfile.companyName != null) ...[
                          SizedBox(height: 12.h),
                          ExperienceCard(
                            jobTitle: userProfile.experienceJobTitle ??
                                userProfile.jobTitle,
                            companyName: userProfile.companyName ?? '',
                            duration: userProfile.duration ?? '',
                          ),
                        ],
                      ],
                    ),
                  ),
              };
            },
          ),
        ),
      ),
    );
  }
}