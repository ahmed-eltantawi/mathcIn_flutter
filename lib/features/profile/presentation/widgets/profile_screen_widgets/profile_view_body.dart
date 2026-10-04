import 'package:MatchIn/core/utils/profile_formatters.dart';
import 'package:MatchIn/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/profile_state.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/profile_header.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/profile_overview_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileViewBody extends StatelessWidget {
  const ProfileViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      children: [
        const ProfileHeader(),

        SizedBox(height: 16.h),

        BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is ProfileFailure) {
              return Center(child: Text(state.message));
            }

            if (state is ProfileSuccess) {
              final profile = state.profile;
              final details = profile.profile;

              return ProfileOverviewCard(
                name: profile.user.name,
                avatarUrl: profile.user.avatar,
                jobTitle: details?.jobTitle ?? '',
                location: ProfileFormatters.location(
                  details,
                ),
                summary: details?.professionalSummary ?? '',
                githubUrl: details?.githubUrl,
                linkedinUrl: details?.linkedinUrl,
              );
            }

            return const SizedBox.shrink();
          },
        ),

        // Education
        // Experience
        // Skills
        // Projects
        // CV
        // Career Preferences
      ],
    );
  }
}
