import 'package:MatchIn/features/auth/presentation/widgets/password_requirement_tile.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PasswordRequirementsSection extends StatelessWidget {
  const PasswordRequirementsSection({
    super.key,
    required this.hasMinLength,
    required this.hasNumber,
    required this.hasSpecialChar,
  });

  final bool hasMinLength;
  final bool hasNumber;
  final bool hasSpecialChar;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 12.h),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).passwordRequirements,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          PasswordRequirementTile(
            text: S.of(context).reqMin8Chars,
            isMet: hasMinLength,
          ),
          PasswordRequirementTile(
            text: S.of(context).reqAtLeastOneNumber,
            isMet: hasNumber,
          ),
          PasswordRequirementTile(
            text: S.of(context).reqAtLeastOneSpecial,
            isMet: hasSpecialChar,
          ),
        ],
      ),
    );
  }
}
