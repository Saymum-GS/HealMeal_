import 'package:equatable/equatable.dart';
import '../../../core/data/models.dart';

enum LabTestStatus { initial, loading, loaded, error }

class LabTestState extends Equatable {
  final LabTestStatus status;
  final List<LabTest> allTests;
  final String? errorMessage;

  const LabTestState({
    this.status = LabTestStatus.initial,
    this.allTests = const [],
    this.errorMessage,
  });

  LabTestState copyWith({
    LabTestStatus? status,
    List<LabTest>? allTests,
    String? errorMessage,
  }) {
    return LabTestState(
      status: status ?? this.status,
      allTests: allTests ?? this.allTests,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, allTests, errorMessage];
}

