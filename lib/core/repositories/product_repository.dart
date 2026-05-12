import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models.dart';

class ProductRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Product>> getProductsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    
    final snapshot = await _firestore.collection('products')
        .where(FieldPath.documentId, whereIn: ids)
        .get();
        
    return snapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList();
  }

  Future<Product?> getProductById(String id) async {
    final doc = await _firestore.collection('products').doc(id).get();
    if (!doc.exists) return null;
    return Product.fromMap(doc.data()!, doc.id);
  }

  Stream<List<Product>> watchFlashSale() {
    return _firestore.collection('products')
        .where('isFlashSale', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Product.fromMap(d.data(), d.id)).toList());
  }
}
