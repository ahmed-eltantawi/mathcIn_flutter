import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

enum CvStatus { empty, picking, selected, failure }

class CvState extends Equatable {
  const CvState({
    this.status = CvStatus.empty,
    this.file,
    this.errorMessage,
  });

  final CvStatus status;
  final PlatformFile? file;
  final String? errorMessage;

  CvState copyWith({
    CvStatus? status,
    PlatformFile? file,
    String? errorMessage,
  }) {
    return CvState(
      status: status ?? this.status,
      file: file ?? this.file,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    file?.name,
    errorMessage,
  ];
}
