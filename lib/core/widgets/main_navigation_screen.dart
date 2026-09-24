import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/routing/cubit/main_navigation_cubit.dart';
import 'package:MatchIn/core/widgets/views/saved_jobs_view.dart';
import 'package:MatchIn/features/chatbot/presentation/views/ai_chat_view.dart';
import 'package:MatchIn/features/home/presentation/views/home_view.dart';
import 'package:MatchIn/features/profile/presentation/pages/profile_view.dart';
import 'package:MatchIn/features/roadmap/presentation/views/roadmap_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  static const List<Widget> _pages = [
    AiChatView(),
    SavedJobsView(),
    HomeView(),
    RoadmapView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;
    final l10n = context.l10n;

    return BlocBuilder<MainNavigationCubit, int>(
      builder: (context, currentIndex) {
        return Scaffold(
          body: IndexedStack(
            index: currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(
                    alpha: 0.05,
                  ),
                  blurRadius: 10.r,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
                child: GNav(
                  selectedIndex: currentIndex,
                  onTabChange: (index) {
                    context
                        .read<MainNavigationCubit>()
                        .selectTab(index);
                  },
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  gap: 6.w,
                  iconSize: 24.r,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  color: colors.onSurface.withValues(
                    alpha: 0.6,
                  ),
                  activeColor: colors.primary,
                  tabBackgroundColor: colors.primary
                      .withValues(alpha: 0.12),
                  textStyle: textTheme.labelMedium
                      ?.copyWith(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                  tabs: [
                    GButton(
                      icon: Icons.smart_toy_outlined,
                      text: l10n.chatBot,
                    ),
                    GButton(
                      icon: Icons.bookmark_outline,
                      text: l10n.savedJobs,
                    ),
                    GButton(
                      icon: Icons.home_outlined,
                      text: l10n.home,
                    ),
                    GButton(
                      icon: Icons.route_outlined,
                      text: l10n.roadMap,
                    ),
                    GButton(
                      icon: Icons.person_outline,
                      text: l10n.profile,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
