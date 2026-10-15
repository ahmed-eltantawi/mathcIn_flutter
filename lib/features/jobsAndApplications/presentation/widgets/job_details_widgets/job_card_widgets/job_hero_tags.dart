import 'package:flutter/widgets.dart';

///* Centralized Hero tag factory for job shared-element transitions.
///* Tags combine the list source prefix + job id + element type so the same
///* job rendered in Home, Feed, Search, and Saved never collides, while the
///* details screen reuses the originating prefix passed via navigation extra.
abstract class JobHeroTags {
  static String avatar({required String prefix, required String jobId}) =>
      '${prefix}_avatar_$jobId';

  static String title({required String prefix, required String jobId}) =>
      '${prefix}_title_$jobId';

  static String company({required String prefix, required String jobId}) =>
      '${prefix}_company_$jobId';

  /// Wraps [child] in a Hero unless reduced-motion is requested.
  static Widget maybeHero({
    required BuildContext context,
    required String tag,
    required Widget child,
  }) {
    final reduceMotion =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) return child;
    return Hero(tag: tag, child: child);
  }
}
