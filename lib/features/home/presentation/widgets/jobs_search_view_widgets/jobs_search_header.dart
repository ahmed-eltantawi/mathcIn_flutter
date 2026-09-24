import 'package:MatchIn/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class JobsSearchHeader extends StatelessWidget {
  const JobsSearchHeader({super.key, this.onBack, this.onFiltersTap});

  final VoidCallback? onBack;
  final VoidCallback? onFiltersTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(8.w, 8.h, 8.w, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack ?? () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded),
          ),

          Expanded(
            child: Text(
              context.l10n.searchJobsTitle,
              textAlign: TextAlign.center,
              style: context.textTheme.titleLarge?.copyWith(
                color: context.colors.primary,
              ),
            ),
          ),

          IconButton(
            onPressed: onFiltersTap ?? () {},
            icon: Icon(Icons.tune_rounded, color: context.colors.primary),
          ),
        ],
      ),
    );
  }
}
