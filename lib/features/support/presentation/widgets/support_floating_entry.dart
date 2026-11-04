import 'package:MatchIn/core/widgets/helpers/url_launcher_helper.dart';
import 'package:MatchIn/features/support/presentation/widgets/support_contact_card.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Adds a small, app-wide support shortcut above the current route.
class SupportFloatingEntry extends StatefulWidget {
  const SupportFloatingEntry({required this.child, super.key});

  final Widget child;

  @override
  State<SupportFloatingEntry> createState() => _SupportFloatingEntryState();
}

class _SupportFloatingEntryState extends State<SupportFloatingEntry> {
  static const String _email = 'zaskizaski13@gmail.com';
  static const String _linkedIn =
      'https://www.linkedin.com/in/ahmed-elzaher13';

  bool _isExpanded = false;

  Future<void> _openLink(String value) async {
    await UrlLauncherHelper.open(value);
  }

  Future<void> _openEmail() async {
    await UrlLauncherHelper.openEmail(_email);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomOffset = bottomInset > 0 ? bottomInset + 12.h : 84.h;

    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _isExpanded = false),
              child: ColoredBox(
                color: Theme.of(context).colorScheme.scrim.withValues(
                  alpha: 0.08,
                ),
              ),
            ),
          ),
        PositionedDirectional(
          start: 16.w,
          bottom: bottomOffset,
          child: AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            alignment: AlignmentDirectional.bottomStart,
            child: _isExpanded
                ? SizedBox(
                    width: (MediaQuery.sizeOf(context).width - 32.w)
                        .clamp(0.0, 340.w)
                        .toDouble(),
                    child: SupportContactCard(
                      email: _email,
                      onClose: () => setState(() => _isExpanded = false),
                      onEmailTap: _openEmail,
                      onLinkedInTap: () => _openLink(_linkedIn),
                    ),
                  )
                : _SupportButton(
                    onTap: () => setState(() => _isExpanded = true),
                  ),
          ),
        ),
      ],
    );
  }
}

class _SupportButton extends StatelessWidget {
  const _SupportButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: S.of(context).supportTitle,
      child: Material(
        color: colors.primary,
        elevation: 4,
        shadowColor: colors.shadow.withValues(alpha: 0.22),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 48.r,
            height: 48.r,
            child: Icon(
              Icons.support_agent_rounded,
              color: colors.onPrimary,
              size: 24.r,
            ),
          ),
        ),
      ),
    );
  }
}
