import 'package:MatchIn/features/profile/presentation/widgets/edit_education_widgets/education_form.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditEducationViewBody extends StatelessWidget {
  const EditEducationViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return ListView(
      padding: EdgeInsets.all(20.r),
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
            ),
            Expanded(
              child: Text(
                locale.education,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(width: 48.w),
          ],
        ),
        SizedBox(height: 32.h),
        const EducationForm(),
        SizedBox(height: 24.h),
      ],
    );
  }
}
