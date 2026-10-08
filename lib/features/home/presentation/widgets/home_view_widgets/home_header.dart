import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:MatchIn/core/functions/show_image.dart';
import 'package:MatchIn/core/routing/app_routes.dart';
import 'package:MatchIn/core/utils/app_assets.dart';
import 'package:MatchIn/core/widgets/app_circle_icon_button.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              showImage(image: Assets.iconsTextLogo),
              const Spacer(),
              AppCircleIconButton(
                icon: Icons.notifications_none_rounded,
                hasBadge: true,
                tooltip: s.notifications,
                onTap: () {
                  context.push(AppRoutes.knotifications);
                },
              ),
              SizedBox(width: 8.w),
              AppCircleIconButton(
                icon: Icons.settings_outlined,
                tooltip: s.settings,
                onTap: () {
                  context.push(AppRoutes.ksettings);
                },
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            s.greetingUser(userName),
            style: context.textTheme.headlineLarge,
          ),
          SizedBox(height: 4.h),
          Text(
            s.readyToFindYourNextOpportunity,
            style: context.textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}
