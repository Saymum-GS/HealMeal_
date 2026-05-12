import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/repositories/lab_test_repository.dart';
import 'lab_test_state.dart';

class LabTestCubit extends Cubit<LabTestState> {
  final LabTestRepository _repository;

  LabTestCubit({required LabTestRepository repository})
      : _repository = repository,
        super(const LabTestState());

  Future<void> load() async {
    emit(state.copyWith(status: LabTestStatus.loading));
    try {
      final tests = await _repository.fetchLabTests();
      emit(state.copyWith(status: LabTestStatus.loaded, allTests: tests));
    } catch (e) {
      emit(state.copyWith(status: LabTestStatus.error, errorMessage: e.toString()));
    }
  }
}

