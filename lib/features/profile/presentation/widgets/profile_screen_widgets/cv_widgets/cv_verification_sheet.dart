import 'package:MatchIn/core/extensions/bottom_sheet_extensions.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_extraction_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_verify_params.dart';
import 'package:MatchIn/features/profile/presentation/cubits/cv_cubit/cv_upload_cubit.dart';
import 'package:MatchIn/features/profile/presentation/cubits/cv_cubit/cv_upload_state.dart';
import 'package:MatchIn/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Candidate review of AI-extracted CV data before confirmation.
///
/// Edits live in this sheet's controllers, so a failed submission keeps
/// every keystroke: the sheet only closes on [CvVerified]. Submits the
/// real backend extraction id with the documented verify schema.
class CvVerificationSheet extends StatelessWidget {
  const CvVerificationSheet({
    required this.docId,
    required this.extraction,
    super.key,
  });

  final int docId;
  final CvExtractionEntity extraction;

  static Future<bool?> show(
    BuildContext context, {
    required int docId,
    required CvExtractionEntity extraction,
    required CvUploadCubit cubit,
  }) {
    return context.showAppBottomSheet<bool>(
      child: BlocProvider.value(
        value: cubit,
        child: CvVerificationSheet(docId: docId, extraction: extraction),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CvUploadCubit, CvUploadState>(
      listenWhen: (previous, current) =>
          current is CvVerified || current is CvVerifyFailure,
      listener: (context, state) {
        if (state is CvVerified) {
          Navigator.of(context).pop(true);
        }
      },
      child: _VerificationForm(docId: docId, extraction: extraction),
    );
  }
}

class _EditableRow {
  _EditableRow({
    required this.primary,
    this.secondary,
    this.detail,
    this.tertiary,
    this.quaternary,
    this.isCurrent,
  });

  final TextEditingController primary;
  final TextEditingController? secondary;
  final TextEditingController? detail;
  final TextEditingController? tertiary;
  final TextEditingController? quaternary;
  final bool? isCurrent;

  void dispose() {
    primary.dispose();
    secondary?.dispose();
    detail?.dispose();
    tertiary?.dispose();
    quaternary?.dispose();
  }

  bool get isEmpty =>
      primary.text.trim().isEmpty &&
      (secondary?.text.trim().isEmpty ?? true) &&
      (detail?.text.trim().isEmpty ?? true) &&
      (tertiary?.text.trim().isEmpty ?? true) &&
      (quaternary?.text.trim().isEmpty ?? true);
}

class _VerificationForm extends StatefulWidget {
  const _VerificationForm({required this.docId, required this.extraction});

  final int docId;
  final CvExtractionEntity extraction;

  @override
  State<_VerificationForm> createState() => _VerificationFormState();
}

class _VerificationFormState extends State<_VerificationForm> {
  late List<_EditableRow> _skills;
  late List<_EditableRow> _experiences;
  late List<_EditableRow> _educations;

  @override
  void initState() {
    super.initState();
    _skills = widget.extraction.skills
        .map(
          (item) => _EditableRow(
            primary: TextEditingController(text: item.label),
            secondary: TextEditingController(
              text: item.proficiency?.toLowerCase() ?? 'beginner',
            ),
          ),
        )
        .toList();
    _experiences = widget.extraction.experiences
        .map(
          (item) => _EditableRow(
            primary: TextEditingController(
              text: item.jobTitle ?? item.title ?? '',
            ),
            secondary: TextEditingController(
              text: item.companyName ?? item.subtitle ?? '',
            ),
            detail: TextEditingController(text: item.detail ?? ''),
            tertiary: TextEditingController(text: item.startDate ?? ''),
            quaternary: TextEditingController(text: item.endDate ?? ''),
            isCurrent: item.isCurrent,
          ),
        )
        .toList();
    _educations = widget.extraction.educations
        .map(
          (item) => _EditableRow(
            primary: TextEditingController(
              text: item.institution ?? item.subtitle ?? '',
            ),
            secondary: TextEditingController(
              text: item.degree ?? item.title ?? '',
            ),
            detail: TextEditingController(text: item.fieldOfStudy ?? ''),
            tertiary: TextEditingController(text: item.startDate ?? ''),
            quaternary: TextEditingController(text: item.endDate ?? ''),
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    for (final row in [..._skills, ..._experiences, ..._educations]) {
      row.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);
    return BlocBuilder<CvUploadCubit, CvUploadState>(
      builder: (context, state) {
        final verifying = state is CvVerifying;
        final failure = state is CvVerifyFailure ? state : null;
        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale.reviewCv,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4.h),
                Text(
                  locale.reviewInformationBeforeContinuing,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                SizedBox(height: 16.h),
                if (failure != null) _FailureBanner(message: failure.message),
                _Section(
                  title: locale.skills,
                  rows: _skills,
                  primaryHint: locale.skills,
                  fieldHints: [locale.skills],
                  secondaryOptions: const [
                    'beginner',
                    'intermediate',
                    'advanced',
                    'expert',
                  ],
                  onAdd: () => setState(
                    () => _skills.add(
                      _EditableRow(
                        primary: TextEditingController(),
                        secondary: TextEditingController(text: 'beginner'),
                      ),
                    ),
                  ),
                  onRemove: (row) => setState(() {
                    row.dispose();
                    _skills.remove(row);
                  }),
                ),
                _Section(
                  title: locale.experience,
                  rows: _experiences,
                  primaryHint: locale.experience,
                  secondaryHint: locale.reviewCv,
                  fieldHints: [
                    locale.jobTitle,
                    locale.company,
                    locale.reviewCv,
                    '${locale.startDate} (YYYY-MM-DD)',
                    '${locale.endDate} (YYYY-MM-DD)',
                  ],
                  onAdd: () => setState(
                    () => _experiences.add(
                      _EditableRow(
                        primary: TextEditingController(),
                        secondary: TextEditingController(),
                        detail: TextEditingController(),
                        tertiary: TextEditingController(),
                        quaternary: TextEditingController(),
                      ),
                    ),
                  ),
                  onRemove: (row) => setState(() {
                    row.dispose();
                    _experiences.remove(row);
                  }),
                ),
                _Section(
                  title: locale.education,
                  rows: _educations,
                  primaryHint: locale.education,
                  fieldHints: [
                    locale.institutionHint,
                    locale.degree,
                    locale.fieldOfStudy,
                    '${locale.startDate} (YYYY-MM-DD)',
                    '${locale.endDate} (YYYY-MM-DD)',
                  ],
                  onAdd: () => setState(
                    () => _educations.add(
                      _EditableRow(
                        primary: TextEditingController(),
                        secondary: TextEditingController(),
                        detail: TextEditingController(),
                        tertiary: TextEditingController(),
                        quaternary: TextEditingController(),
                      ),
                    ),
                  ),
                  onRemove: (row) => setState(() {
                    row.dispose();
                    _educations.remove(row);
                  }),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: verifying ? null : () => _submit(context),
                    child: verifying
                        ? SizedBox(
                            width: 20.r,
                            height: 20.r,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(locale.confirm),
                  ),
                ),
                SizedBox(height: 8.h),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: verifying
                        ? null
                        : () => Navigator.of(context).pop(false),
                    child: Text(locale.cancel),
                  ),
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        );
      },
    );
  }

  void _submit(BuildContext context) {
    final extractionId = widget.extraction.extractionId;
    if (extractionId == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(S.of(context).somethingWentWrong)),
        );
      return;
    }
    final skills = _skills
        .where((row) => !row.isEmpty)
        .map(
          (row) => CvExtractedItem(
            name: row.primary.text.trim(),
            proficiency: row.secondary?.text.trim(),
          ),
        )
        .toList();
    final experiences = _experiences
        .where((row) => !row.isEmpty)
        .map(
          (row) => CvExtractedItem(
            jobTitle: row.primary.text.trim(),
            companyName: row.secondary?.text.trim(),
            detail: row.detail?.text.trim(),
            startDate: row.tertiary?.text.trim(),
            endDate: row.quaternary?.text.trim(),
            isCurrent: row.isCurrent,
          ),
        )
        .toList();
    final educations = _educations
        .where((row) => !row.isEmpty)
        .map(
          (row) => CvExtractedItem(
            institution: row.primary.text.trim(),
            degree: row.secondary?.text.trim(),
            fieldOfStudy: row.detail?.text.trim(),
            startDate: row.tertiary?.text.trim(),
            endDate: row.quaternary?.text.trim(),
          ),
        )
        .toList();
    if (skills.any((item) => !item.isSkillComplete) ||
        experiences.any((item) => !item.isExperienceComplete) ||
        educations.any((item) => !item.isEducationComplete)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(S.of(context).somethingWentWrong)),
        );
      return;
    }
    final params = CvVerifyParams(
      extractionId: extractionId,
      action: 'edit',
      skills: skills,
      experiences: experiences,
      educations: educations,
    );
    context.read<CvUploadCubit>().verifyExtraction(params);
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.rows,
    required this.primaryHint,
    required this.fieldHints,
    this.secondaryOptions,
    this.secondaryHint,
    required this.onAdd,
    required this.onRemove,
  });

  final String title;
  final List<_EditableRow> rows;
  final String primaryHint;
  final List<String> fieldHints;
  final List<String>? secondaryOptions;
  final String? secondaryHint;
  final VoidCallback onAdd;
  final ValueChanged<_EditableRow> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              tooltip: title,
              icon: const Icon(Icons.add_circle_outline_rounded),
              onPressed: onAdd,
            ),
          ],
        ),
        if (rows.isEmpty)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Text('—', style: Theme.of(context).textTheme.bodySmall),
          ),
        for (final row in rows)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _field(row.primary, fieldHints[0]),
                      if (row.secondary != null) ...[
                        SizedBox(height: 6.h),
                        if (secondaryOptions != null)
                          DropdownButtonFormField<String>(
                            initialValue:
                                secondaryOptions!.contains(row.secondary!.text)
                                ? row.secondary!.text
                                : null,
                            decoration: InputDecoration(
                              hintText: secondaryHint ?? primaryHint,
                              isDense: true,
                            ),
                            items: secondaryOptions!
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) =>
                                row.secondary!.text = value ?? '',
                          )
                        else
                          _field(row.secondary!, fieldHints[1]),
                      ],
                      if (row.detail != null) ...[
                        SizedBox(height: 6.h),
                        _field(row.detail!, fieldHints[2], maxLines: 2),
                      ],
                      if (row.tertiary != null) ...[
                        SizedBox(height: 6.h),
                        _field(row.tertiary!, fieldHints[3]),
                      ],
                      if (row.quaternary != null) ...[
                        SizedBox(height: 6.h),
                        _field(row.quaternary!, fieldHints[4]),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                  onPressed: () => onRemove(row),
                ),
              ],
            ),
          ),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) => TextField(
    controller: controller,
    maxLines: maxLines,
    decoration: InputDecoration(hintText: hint, isDense: true),
  );
}

class _FailureBanner extends StatelessWidget {
  const _FailureBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: colors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colors.error, size: 20.r),
          SizedBox(width: 8.w),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
