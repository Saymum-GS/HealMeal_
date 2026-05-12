import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models.dart';

class PrescriptionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPrescription({
    required String userId,
    required Uint8List bytes,
    required String fileName,
    String mimeType = 'image/jpeg',
  }) async {
    // 1. Convert to Base64
    final base64String = base64Encode(bytes);
    final dataUri = 'data:$mimeType;base64,$base64String';

    // 2. Save to Firestore
    final docRef = _firestore.collection('prescriptions').doc();
    final prescription = Prescription(
      id: docRef.id,
      userId: userId,
      imageUrl: dataUri,
      status: PrescriptionStatus.pending,
      uploadedAt: DateTime.now(),
      fileName: fileName,
    );

    await docRef.set(prescription.toMap());

    return dataUri;
  }

  Stream<List<Prescription>> getUserPrescriptions(String userId) {
    return _firestore
        .collection('prescriptions')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => Prescription.fromMap(doc.data(), doc.id))
          .toList();
      // Sort in-memory to avoid Firestore Composite Index requirement
      list.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));
      return list;
    });
  }
}
