import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePhoneField extends StatelessWidget {
  const ProfilePhoneField({
    required this.controller,
    required this.countryCode,
    required this.countryCodes,
    required this.onCountryCodeChanged,
    super.key,
  });

  final TextEditingController controller;
  final String? countryCode;
  final Map<String, String> countryCodes;
  final ValueChanged<String?> onCountryCodeChanged;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final theme = Theme.of(context);
    final validCountryCode =
        countryCode != null && countryCodes.containsKey(countryCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale.phoneNumber,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 116.w,
              child: DropdownButtonFormField<String>(
                initialValue: validCountryCode ? countryCode : null,
                isExpanded: true,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 17.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                items: countryCodes.entries
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Text(entry.value),
                      ),
                    )
                    .toList(),
                onChanged: countryCodes.isEmpty ? null : onCountryCodeChanged,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 17.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
