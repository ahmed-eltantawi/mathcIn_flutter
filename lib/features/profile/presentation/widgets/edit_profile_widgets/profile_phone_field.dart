import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePhoneField extends StatelessWidget {
  const ProfilePhoneField({
    required this.controller,
    required this.countryCode,
    required this.countryCodes,
    required this.onCountryCodeChanged,
    this.enabled = true,
    super.key,
  });

  final TextEditingController controller;
  final String? countryCode;
  final Map<String, String> countryCodes;
  final ValueChanged<String?> onCountryCodeChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final availableCodes = Map<String, String>.from(countryCodes);

    final currentCode = countryCode?.trim();

    if (currentCode != null &&
        currentCode.isNotEmpty &&
        !availableCodes.containsKey(currentCode)) {
      availableCodes[currentCode] = currentCode;
    }

    final selectedCode =
        currentCode != null && availableCodes.containsKey(currentCode)
        ? currentCode
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          locale.phoneNumber,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colors.onSurfaceVariant,
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
                key: ValueKey(selectedCode),
                initialValue: selectedCode,
                isExpanded: true,

                // Menu rows show name + code, while the closed field
                // shows only the calling code (e.g. "+20").
                selectedItemBuilder: (context) => availableCodes.keys
                    .map((code) => Text(code, overflow: TextOverflow.ellipsis))
                    .toList(),

                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: colors.onSurfaceVariant,
                ),

                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 17.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: theme.dividerColor),
                  ),
                ),

                items: availableCodes.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),

                // Disabled until a verified country-code source is available.
                onChanged: !enabled || countryCodes.isEmpty
                    ? null
                    : onCountryCodeChanged,
              ),
            ),

            SizedBox(width: 12.w),

            Expanded(
              child: TextFormField(
                controller: controller,
                enabled: enabled,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 17.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: theme.dividerColor),
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
