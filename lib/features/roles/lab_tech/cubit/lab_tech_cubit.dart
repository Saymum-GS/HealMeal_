import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/models.dart';
import '../../../../core/repositories/lab_repository.dart';

class LabTechState {
  final List<LabBooking> todayBookings;
  final List<LabBooking> pendingBookings;
  final List<LabBooking> completedBookings;
  final bool isLoading;
  final String? error;

  const LabTechState({
    this.todayBookings = const [],
    this.pendingBookings = const [],
    this.completedBookings = const [],
    this.isLoading = false,
    this.error,
  });

  LabTechState copyWith({
    List<LabBooking>? todayBookings,
    List<LabBooking>? pendingBookings,
    List<LabBooking>? completedBookings,
    bool? isLoading,
    String? error,
  }) {
    return LabTechState(
      todayBookings: todayBookings ?? this.todayBookings,
      pendingBookings: pendingBookings ?? this.pendingBookings,
      completedBookings: completedBookings ?? this.completedBookings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class LabTechCubit extends Cubit<LabTechState> {
  final LabRepository _labRepository;
  StreamSubscription<List<LabBooking>>? _subscription;

  LabTechCubit({required LabRepository labRepository}) 
    : _labRepository = labRepository,
      super(const LabTechState()) {
    _initStream();
  }

  void _initStream() {
    emit(state.copyWith(isLoading: true));
    _subscription = _labRepository.watchBookings().listen(
      (bookings) {
        final pending = bookings.where((b) => b.status == LabBookingStatus.upcoming || b.status == LabBookingStatus.processing || b.status == LabBookingStatus.collected).toList();
        final completed = bookings.where((b) => b.status == LabBookingStatus.completed).toList();
        
        emit(state.copyWith(
          todayBookings: bookings,
          pendingBookings: pending,
          completedBookings: completed,
          isLoading: false,
        ));
      },
      onError: (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      },
    );
  }

  Future<void> markCollected(String id) async {
    await _labRepository.updateBookingStatus(id, LabBookingStatus.collected);
  }

  Future<void> markCompleted(String id) async {
    await _labRepository.updateBookingStatus(id, LabBookingStatus.completed);
  }

  Future<void> uploadReport(String id, String reportUrl) async {
    await _labRepository.attachReport(id, reportUrl);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
