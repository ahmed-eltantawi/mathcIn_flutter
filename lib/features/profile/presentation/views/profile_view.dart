// import 'package:MatchIn/core/services/services_locator.dart';
// import 'package:MatchIn/features/profile/presentation/cubits/profile_cubit.dart';
// import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/profile_view_body.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class ProfileView extends StatelessWidget {
//   const ProfileView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => getIt<ProfileCubit>()..getCandidateProfile(),
//       child: const Scaffold(body: SafeArea(child: ProfileViewBody())),
//     );
//   }
// }

// ! mock
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:MatchIn/features/profile/data/debug/profile_cache_seeder.dart';
import 'package:MatchIn/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/profile_view_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<ProfileCubit>();

        _seedAndLoadProfile(cubit);

        return cubit;
      },
      child: const Scaffold(
        body: SafeArea(child: ProfileViewBody()),
      ),
    );
  }

  Future<void> _seedAndLoadProfile(
    ProfileCubit cubit,
  ) async {
    final seeder = ProfileCacheSeeder(
      localDataSource: getIt<ProfileLocalDataSource>(),
    );

    await seeder.seed();

    await cubit.getCandidateProfile();
  }
}
