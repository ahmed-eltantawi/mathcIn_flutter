import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

/// Bottom-sheet picker for the avatar image source.
///
/// Completes with the selected [ImageSource], or null when dismissed
/// or cancelled. Performs no picking itself.
class AvatarSourceSheet extends StatelessWidget {
  const AvatarSourceSheet({super.key});

  static Future<ImageSource?> show(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => const AvatarSourceSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: Text(locale.takePhoto),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: Text(locale.chooseFromGallery),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(Icons.close_rounded),
            title: Text(locale.cancel),
            onTap: () => Navigator.of(context).pop(),
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}
