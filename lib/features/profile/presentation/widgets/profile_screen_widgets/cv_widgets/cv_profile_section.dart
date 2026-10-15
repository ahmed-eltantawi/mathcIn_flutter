import 'package:MatchIn/core/functions/preview_cv_file.dart';
import 'package:MatchIn/core/networking/connectivity_cubit.dart';
import 'package:MatchIn/core/networking/connectivity_state.dart';
import 'package:MatchIn/core/services/file_picker_service.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_document_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_upload_input.dart';
import 'package:MatchIn/features/profile/presentation/cubits/cv_cubit/cv_upload_cubit.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/profile_form_validator.dart';
import 'package:MatchIn/features/profile/presentation/cubits/cv_cubit/cv_upload_state.dart';
import 'package:MatchIn/features/profile/presentation/cubits/profile_cubit/profile_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/profile_cubit/profile_state.dart';
import 'package:MatchIn/core/widgets/helpers/url_launcher_helper.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/cv_widgets/cv_file_validator.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/cv_widgets/cv_profile_card.dart';
import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/cv_widgets/cv_sync_banner.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Bridges the Main Profile CV card with the upload flow.
///
/// The displayed CV metadata always comes from [cvDocument] (Main
/// Profile state, remote + cache, reconciled with pending uploads
/// and upload markers by the repository). [CvUploadCubit] only tracks
/// the upload request itself, so a failed replacement never disturbs
/// the existing card.
class CvProfileSection extends StatelessWidget {
  const CvProfileSection({required this.cvDocument, super.key});

  final CvDocumentEntity? cvDocument;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CvUploadCubit>(
      create: (_) => getIt<CvUploadCubit>(),
      child: _ConnectivityRetryListener(
        child: _CvUploadFlow(cvDocument: cvDocument),
      ),
    );
  }
}

/// Retries a stored pending upload when connectivity returns.
///
/// The app-wide [ConnectivityCubit] is optional here so widget tests
/// can pump the section without providing it.
class _ConnectivityRetryListener extends StatelessWidget {
  const _ConnectivityRetryListener({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    ConnectivityCubit? connectivity;
    try {
      connectivity = context.read<ConnectivityCubit>();
    } catch (_) {
      connectivity = null;
    }
    if (connectivity == null) return child;

    return BlocListener<ConnectivityCubit, ConnectivityState>(
      listenWhen: (previous, current) =>
          current.isReconnected || current.isOnline,
      listener: (context, _) {
        context.read<CvUploadCubit>().retryPending();
      },
      child: child,
    );
  }
}

class _CvUploadFlow extends StatefulWidget {
  const _CvUploadFlow({required this.cvDocument});

  final CvDocumentEntity? cvDocument;

  @override
  State<_CvUploadFlow> createState() => _CvUploadFlowState();
}

class _CvUploadFlowState extends State<_CvUploadFlow> {
  /// Locally cached filename used as a last-resort display fallback
  /// when a persisted document carries no filename (server records
  /// expose only id/status) and no in-memory upload state exists
  /// (e.g. fresh navigation with a reset cubit).
  String? _cachedFileName;

  @override
  void initState() {
    super.initState();
    // --- Restore a stored pending upload and opportunistically sync
    // --- it. Harmless while offline: the pending state is kept. ---
    // --- Also resolves the locally cached filename so a document
    // --- without a server filename still renders an uploaded UI. ---
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final cubit = context.read<CvUploadCubit>();
      await cubit.loadPending();
      if (!mounted) return;
      if (cubit.state is CvUploadPending) {
        await cubit.retryPending();
        if (!mounted) return;
      }
      final local = await cubit.localFile();
      if (!mounted) return;
      final name = local?.fileName.trim();
      if (name != null && name.isNotEmpty) {
        setState(() => _cachedFileName = name);
      }
    });
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickAndUpload(BuildContext context) async {
    final cubit = context.read<CvUploadCubit>();
    if (cubit.state is CvUploading) return;
    final locale = S.of(context);

    final file = await getIt<FilePickerService>().pickCvBytes();
    if (!context.mounted) return;
    // User dismissed the picker: stay silent.
    if (file == null) return;

    final error = CvFileValidator.validate(
      fileName: file.name,
      sizeBytes: file.bytes.length,
      hasContent: file.bytes.isNotEmpty,
      unsupportedMessage: locale.cvUnsupportedFileType,
      tooLargeMessage: locale.cvFileTooLarge,
      emptyMessage: locale.cvEmptyFile,
    );
    if (error != null) {
      _showMessage(context, error);
      return;
    }

    await cubit.upload(
      CvUploadInput(
        fileName: file.name,
        extension: CvFileValidator.extensionOf(file.name),
        sizeBytes: file.bytes.length,
        bytes: file.bytes,
      ),
    );
  }

  Future<void> _view(BuildContext context) async {
    final document = widget.cvDocument;
    if (UrlLauncherHelper.isViewable(document?.fileUrl)) {
      final opened = await UrlLauncherHelper.open(document?.fileUrl);
      if (!context.mounted) return;
      if (!opened) {
        _showMessage(context, S.of(context).cvViewFailed);
      }
      return;
    }
    // --- The backend exposes no file URL: preview the locally kept file. ---
    final local = await context.read<CvUploadCubit>().localFile();
    if (!context.mounted) return;
    final bytes = local?.bytes;
    if (bytes == null || bytes.isEmpty) {
      _showMessage(context, S.of(context).cvViewFailed);
      return;
    }
    final opened = await previewCvBytes(
      fileName: local!.fileName,
      bytes: bytes,
    );
    if (!context.mounted) return;
    if (!opened) {
      _showMessage(context, S.of(context).cvViewFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CvUploadCubit, CvUploadState>(
      listener: (context, state) async {
        final locale = S.of(context);
        if (state is CvUploadFailure) {
          final message = state.message.trim().isEmpty
              ? locale.somethingWentWrong
              : state.message;
          _showMessage(context, message);
          return;
        }
        if (state is CvUploadSuccess) {
          _showMessage(context, locale.cvUploadSuccessful);
          await context.read<ProfileCubit>().getCandidateProfile();
          if (!context.mounted) return;
          if (context.read<ProfileCubit>().state is ProfileFailure) {
            _showMessage(context, locale.cvRefreshFailed);
          }
        }
      },
      builder: (context, state) {
        final uploading = state is CvUploading;
        final pendingFileName = state is CvUploadPending
            ? state.fileName
            : null;
        final successFileName = state is CvUploadSuccess
            ? state.fileName
            : null;
        final failure = state is CvUploadFailure ? state : null;

        final document = widget.cvDocument;
        // --- Existence follows the persisted document, not filename
        // --- availability: server records may carry only id/status.
        // --- The upload response carries no filename, so fall back to
        // --- the locally known name while the profile refresh lands. ---
        final displayName =
            _nonEmpty(document?.fileName) ??
            _nonEmpty(document?.originalFilename) ??
            _nonEmpty(successFileName) ??
            _nonEmpty(pendingFileName) ??
            _nonEmpty(_cachedFileName);
        // --- A persisted document means a CV exists even when no
        // --- filename is known anywhere; otherwise fall back to the
        // --- locally known upload name. ---
        final hasCv =
            document != null ||
            (displayName != null && displayName.trim().isNotEmpty);
        // --- Never render an empty filename row for an existing CV:
        // --- fall back to a generic label instead of hiding the card. ---
        final fileNameForDisplay = displayName ?? S.of(context).cv;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pendingFileName != null)
              CvSyncBanner(
                message: S.of(context).cvPendingUpload,
                icon: Icons.cloud_off_outlined,
                onRetry: uploading
                    ? null
                    : () => context.read<CvUploadCubit>().retryPending(),
              ),
            // --- A failed replacement keeps the existing card and
            // --- surfaces a retryable error above it. ---
            if (failure != null)
              CvSyncBanner(
                message: failure.message,
                icon: Icons.error_outline,
                onRetry: uploading || !failure.canRetry
                    ? null
                    : () => context.read<CvUploadCubit>().retryLast(),
              ),
            CvProfileCard(
              // Existence follows the selected current document (or a
              // locally known upload), not file_url availability.
              hasCv: hasCv,
              fileName: hasCv ? fileNameForDisplay : null,
              status: document?.status,
              updatedText: document?.updatedAt == null
                  ? null
                  : ProfileFormValidator.normalizeDateForDisplay(
                      document?.updatedAt,
                    ),
              isUploading: uploading,
              onUpload: uploading ? null : () => _pickAndUpload(context),
              onView: uploading || !hasCv ? null : () => _view(context),
              onReplace: uploading ? null : () => _pickAndUpload(context),
            ),
          ],
        );
      },
    );
  }
}

/// Returns the trimmed [value] when it carries visible content,
/// otherwise null. Keeps display-name fallback chains from treating
/// whitespace-only strings as usable filenames.
String? _nonEmpty(String? value) {
  if (value == null) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
