import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/prescription_repository.dart';
import '../../../core/utils/app_session.dart';
import 'prescription_state.dart';

class PrescriptionCubit extends Cubit<PrescriptionState> {
  final PrescriptionRepository _repository;

  PrescriptionCubit({required PrescriptionRepository repository})
      : _repository = repository,
        super(const PrescriptionState());

  Future<void> upload(Uint8List bytes, String fileName) async {
    final userId = AppSession.userId;
    if (userId == null) {
      emit(state.copyWith(status: PrescriptionCubitStatus.error, errorMessage: 'User not logged in'));
      return;
    }

    emit(state.copyWith(status: PrescriptionCubitStatus.uploading));
    try {
      final url = await _repository.uploadPrescription(
        userId: userId,
        bytes: bytes,
        fileName: fileName,
      );
      emit(state.copyWith(status: PrescriptionCubitStatus.success, uploadedUrl: url));
    } catch (e) {
      emit(state.copyWith(status: PrescriptionCubitStatus.error, errorMessage: e.toString()));
    }
  }

  void reset() {
    emit(const PrescriptionState());
  }
}
