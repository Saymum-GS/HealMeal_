import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models.dart';

class LabTestRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<LabTest>> fetchLabTests() async {
    final snapshot = await _firestore.collection('lab_tests').get();
    return snapshot.docs.map((doc) => _decodeLabTest(doc.data())).toList();
  }

  LabTest _decodeLabTest(Map<String, dynamic> data) {
    return LabTest(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      slug: data['slug'] ?? '',
      mrp: (data['mrp'] ?? 0.0).toDouble(),
      salePrice: (data['salePrice'] ?? 0.0).toDouble(),
      discountPercent: data['discountPercent'] ?? 0,
      reportHours: (data['reportHours'] ?? 24).toString(),
      preparation: data['preparation'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      includes: List<String>.from(data['includes'] ?? []),
    );
  }
}

