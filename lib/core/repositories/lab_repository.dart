import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models.dart';

class LabRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createBooking(LabBooking booking) async {
    await _firestore.collection('lab_bookings').doc(booking.id).set(booking.toMap());
  }

  Stream<List<LabBooking>> watchBookings() {
    return _firestore.collection('lab_bookings').orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => LabBooking.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Stream<List<LabBooking>> watchUserBookings(String userId) {
    return _firestore
        .collection('lab_bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LabBooking.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateBookingStatus(String id, LabBookingStatus status) async {
    await _firestore.collection('lab_bookings').doc(id).update({'status': status.name});
  }

  Future<void> attachReport(String id, String reportUrl) async {
    await _firestore.collection('lab_bookings').doc(id).update({
      'reportUrl': reportUrl,
      'status': LabBookingStatus.completed.name,
    });
  }
}
