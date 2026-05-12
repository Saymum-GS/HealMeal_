import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/models.dart';

class PharmacistState {
  final List<Prescription> pendingPrescriptions;
  final List<Prescription> reviewedPrescriptions;
  final bool isLoading;
  final String? error;

  const PharmacistState({
    this.pendingPrescriptions = const [],
    this.reviewedPrescriptions = const [],
    this.isLoading = false,
    this.error,
  });

  PharmacistState copyWith({
    List<Prescription>? pendingPrescriptions,
    List<Prescription>? reviewedPrescriptions,
    bool? isLoading,
    String? error,
  }) {
    return PharmacistState(
      pendingPrescriptions: pendingPrescriptions ?? this.pendingPrescriptions,
      reviewedPrescriptions: reviewedPrescriptions ?? this.reviewedPrescriptions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PharmacistCubit extends Cubit<PharmacistState> {
  StreamSubscription<QuerySnapshot>? _subscription;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  PharmacistCubit() : super(const PharmacistState()) {
    _initStream();
  }

  void _initStream() {
    emit(state.copyWith(isLoading: true));
    _subscription = _firestore.collection('prescriptions')
      .orderBy('uploadedAt', descending: true)
      .snapshots().listen(
      (snapshot) {
        final all = snapshot.docs.map((doc) {
          return Prescription.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        final pending = all.where((p) => p.status == PrescriptionStatus.pending).toList();
        final reviewed = all.where((p) => p.status != PrescriptionStatus.pending).toList();
        
        emit(state.copyWith(
          pendingPrescriptions: pending,
          reviewedPrescriptions: reviewed,
          isLoading: false,
        ));
      },
      onError: (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      },
    );
  }

  Future<void> updateStatus(String id, PrescriptionStatus newStatus, String note) async {
    await _firestore.collection('prescriptions').doc(id).update({
      'status': newStatus.name,
      'pharmacistNote': note,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateMappedProducts(String id, List<String> productIds) async {
    await _firestore.collection('prescriptions').doc(id).update({
      'mappedProductIds': productIds,
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

