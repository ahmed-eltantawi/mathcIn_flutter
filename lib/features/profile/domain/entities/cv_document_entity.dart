import 'package:MatchIn/features/profile/domain/entities/cv_processing_status.dart';
import 'package:equatable/equatable.dart';

class CvDocumentEntity extends Equatable {
  const CvDocumentEntity({
    this.id,
    this.fileName,
    this.originalFilename,
    this.fileUrl,
    this.status,
    this.version,
    this.isCurrent,
    this.processedAt,
    this.updatedAt,
    this.failureReason,
  });

  final int? id;
  final String? fileName;
  final String? originalFilename;
  final String? fileUrl;
  final CvProcessingStatus? status;
  final int? version;
  final bool? isCurrent;
  final String? processedAt;
  final String? updatedAt;
  final String? failureReason;

  @override
  List<Object?> get props => [
    id,
    fileName,
    originalFilename,
    fileUrl,
    status,
    version,
    isCurrent,
    processedAt,
    updatedAt,
    failureReason,
  ];
}
