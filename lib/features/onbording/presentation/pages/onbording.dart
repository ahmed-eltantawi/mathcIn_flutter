import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:MatchIn/features/onbording/presentation/widgets/career_path_hero_widget.dart';
import 'package:MatchIn/features/onbording/presentation/widgets/job_match_hero_widget.dart';
import 'package:MatchIn/features/onbording/presentation/widgets/onboarding_indicator.dart';
import 'package:MatchIn/features/onbording/presentation/widgets/onboarding_narrative_section.dart';
import 'package:MatchIn/features/onbording/presentation/widgets/onboarding_top_bar.dart';
import 'package:MatchIn/features/onbording/presentation/widgets/opportunity_hero_widget.dart';

class Onb1 extends StatefulWidget {
  const Onb1({super.key});

  @override
  State<Onb1> createState() => _Onb1State();
}

class _Onb1State extends State<Onb1> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finishOnboarding() async {
    await getIt<SharedPreferencesService>().onBoardingViewed();
    if (mounted) {
      context.go(AppRoutes.kRegisterView);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            OnboardingTopBar(
              currentPage: _currentPage,
              totalSteps: 3,
              onSkip: () => _goToPage(2),
              onNotNow: _finishOnboarding,
            ),

            // Main Visual Area (Only Images/Visuals in PageView)
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: OpportunityHeroWidget(),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: JobMatchHeroWidget(),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: CareerPathHeroWidget(),
                  ),
                ],
              ),
            ),

            // Indicator above the text section
            Padding(
              padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
              child: OnboardingIndicator(
                currentPage: _currentPage,
                itemCount: 3,
              ),
            ),

            // Fixed Bottom Content & Button Area
            Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
              child: _buildBottomSection(l10n),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(dynamic l10n) {
    switch (_currentPage) {
      case 0:
        return OnboardingNarrativeSection(
          key: const ValueKey(0),
          title: l10n.turnCvIntoOpportunities,
          subtitle: l10n.turnCvIntoOpportunitiesDesc,
          buttonText: l10n.next,
          onNext: () => _goToPage(1),
        );
      case 1:
        return OnboardingNarrativeSection(
          key: const ValueKey(1),
          title: l10n.getExplainableMatch,
          subtitle: l10n.getExplainableMatchDesc,
          titleFontSize: 26.sp,
          buttonText: l10n.next,
          onNext: () => _goToPage(2),
        );
      case 2:
        return OnboardingNarrativeSection(
          key: const ValueKey(2),
          title: l10n.setupCareerProfile,
          subtitle: l10n.setupCareerProfileDesc,
          buttonText: l10n.start,
          onNext: _finishOnboarding,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
