import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SupportContactCard extends StatelessWidget {
  const SupportContactCard({
    required this.email,
    required this.onClose,
    required this.onEmailTap,
    required this.onLinkedInTap,
    super.key,
  });

  final String email;
  final VoidCallback onClose;
  final VoidCallback onEmailTap;
  final VoidCallback onLinkedInTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = S.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 340.w),
      child: Material(
        color: colors.surface,
        elevation: 12,
        shadowColor: colors.shadow.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(22.r),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.all(18.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42.r,
                    height: 42.r,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(
                      Icons.support_agent_rounded,
                      color: colors.primary,
                      size: 23.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      l10n.supportTitle,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: l10n.supportClose,
                    child: IconButton(
                      onPressed: onClose,
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.close_rounded,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                l10n.supportMessage,
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              SizedBox(height: 14.h),
              _SupportLinkTile(
                icon: Icons.email_outlined,
                label: email,
                onTap: onEmailTap,
              ),
              SizedBox(height: 8.h),
              _SupportLinkTile(
                icon: Icons.link_rounded,
                label: l10n.supportLinkedIn,
                onTap: onLinkedInTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportLinkTile extends StatelessWidget {
  const _SupportLinkTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
          child: Row(
            children: [
              Icon(icon, color: colors.primary, size: 20.r),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.ltr,
                ),
              ),
              Icon(
                Icons.arrow_outward_rounded,
                color: colors.onSurfaceVariant,
                size: 17.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
