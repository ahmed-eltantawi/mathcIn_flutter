import 'dart:typed_data';

import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Result of the avatar preview dialog.
enum AvatarPreviewAction {
  /// Attempt upload (currently reports pending backend support).
  confirm,

  /// Discard the preview and pick another image.
  retake,

  /// Discard the preview and return to the form.
  cancel,
}

/// Shows the staged avatar image before confirmation.
///
/// Displays the in-memory bytes only; confirming never claims the
/// image was saved. The pending-backend notice sets that expectation
/// before the user confirms.
class AvatarPreviewDialog extends StatelessWidget {
  const AvatarPreviewDialog({
    required this.bytes,
    required this.fileName,
    super.key,
  });

  final Uint8List bytes;
  final String fileName;

  static Future<AvatarPreviewAction?> show(
    BuildContext context, {
    required Uint8List bytes,
    required String fileName,
  }) {
    return showDialog<AvatarPreviewAction>(
      context: context,
      builder: (_) => AvatarPreviewDialog(bytes: bytes, fileName: fileName),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AlertDialog(
      title: Text(locale.previewPhoto),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.memory(
                bytes,
                height: 220.h,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => SizedBox(
                  height: 220.h,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              fileName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              locale.avatarUploadUnavailable,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(AvatarPreviewAction.cancel),
          child: Text(locale.cancel),
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(AvatarPreviewAction.retake),
          child: Text(locale.chooseAnother),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(AvatarPreviewAction.confirm),
          child: Text(locale.saveChanges),
        ),
      ],
    );
  }
}
