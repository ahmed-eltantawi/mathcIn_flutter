import 'package:MatchIn/features/profile/domain/entities/cv_extraction_entity.dart';
import 'package:MatchIn/features/profile/domain/entities/cv_processing_status.dart';
import 'package:equatable/equatable.dart';

/// Background extraction status for one CV document, plus the extracted
/// payload once the backend provides one.
class CvExtractionStatusEntity extends Equatable {
  const CvExtractionStatusEntity({
    this.documentId,
    this.status,
    this.extraction,
    this.errorMessage,
    this.fileName,
  });

  final int? documentId;
  final CvProcessingStatus? status;
  final CvExtractionEntity? extraction;
  final String? errorMessage;
  final String? fileName;

  bool get isTerminal =>
      status == CvProcessingStatus.analyzed ||
      status == CvProcessingStatus.failed;

  @override
  List<Object?> get props => [
    documentId,
    status,
    extraction,
    errorMessage,
    fileName,
  ];
}
