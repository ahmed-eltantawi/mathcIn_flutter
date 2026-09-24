import 'package:MatchIn/core/services/file_picker_service.dart';
import 'package:MatchIn/features/jobsAndApplications/presentation/cubit/cv_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CvCubit extends Cubit<CvState> {
  CvCubit({required this._filePickerService})
    : super(const CvState());

  final FilePickerService _filePickerService;

  Future<void> pickCv() async {
    emit(state.copyWith(status: CvStatus.picking));

    try {
      final file = await _filePickerService.pickCv();

      if (file == null) {
        emit(
          state.file == null
              ? const CvState()
              : state.copyWith(status: CvStatus.selected),
        );

        return;
      }

      emit(CvState(status: CvStatus.selected, file: file));
    } catch (_) {
      emit(
        state.copyWith(
          status: CvStatus.failure,
          errorMessage: 'Unable to select CV',
        ),
      );
    }
  }
}
