import 'package:equatable/equatable.dart';

enum PrescriptionCubitStatus { initial, uploading, success, error }

class PrescriptionState extends Equatable {
  final PrescriptionCubitStatus status;
  final String? errorMessage;
  final String? uploadedUrl;

  const PrescriptionState({
    this.status = PrescriptionCubitStatus.initial,
    this.errorMessage,
    this.uploadedUrl,
  });

  @override
  List<Object?> get props => [status, errorMessage, uploadedUrl];

  PrescriptionState copyWith({
    PrescriptionCubitStatus? status,
    String? errorMessage,
    String? uploadedUrl,
  }) {
    return PrescriptionState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadedUrl: uploadedUrl ?? this.uploadedUrl,
    );
  }
}

