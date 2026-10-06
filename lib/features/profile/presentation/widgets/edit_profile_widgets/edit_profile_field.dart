import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditProfileField extends StatelessWidget {
  const EditProfileField({
    required this.label,
    required this.controller,
    super.key,
    this.hintText,
    this.readOnly = false,
    this.onTap,
    this.keyboardType,
    this.prefix,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final Widget? prefix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefix,
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
      ],
    );
  }
}
