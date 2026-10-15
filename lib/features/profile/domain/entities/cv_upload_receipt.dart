import 'package:equatable/equatable.dart';

/// Minimal receipt returned by `POST /cv/upload`.
///
/// The upload response carries a receipt (`id`, `version`, `status`),
/// not a complete CV document. The Main Profile card refreshes from
/// `GET /candidate/profile` afterwards for authoritative metadata.
class CvUploadReceipt extends Equatable {
  const CvUploadReceipt({required this.id, this.version, this.status});

  final int id;
  final int? version;
  final String? status;

  @override
  List<Object?> get props => [id, version, status];
}
