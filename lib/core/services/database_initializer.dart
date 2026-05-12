import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/products.dart';
import '../data/lab_tests.dart';
import '../data/models.dart';

class DatabaseInitializer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> initialize() async {
    await _seedProducts();
    await _seedLabTests();
    await _ensureAdmin();
  }

  static Future<void> _seedProducts() async {
    final collection = _firestore.collection('products');
    final snapshot = await collection.limit(1).get();
    
    if (snapshot.docs.isNotEmpty) return; // Already seeded

    final batch = _firestore.batch();
    for (final product in initialMedicines) {
      final docRef = collection.doc(product.id);
      batch.set(docRef, _encodeProduct(product));
    }
    await batch.commit();
  }

  static Future<void> _seedLabTests() async {
    final collection = _firestore.collection('lab_tests');
    final snapshot = await collection.limit(1).get();
    
    if (snapshot.docs.isNotEmpty) return; // Already seeded

    final batch = _firestore.batch();
    for (final test in initialLabTests) {
      final docRef = collection.doc(test.id);
      batch.set(docRef, _encodeLabTest(test));
    }
    await batch.commit();
  }

  static Future<void> _ensureAdmin() async {
    // This is handled in AuthCubit on login, but we can pre-emptively check if current user is admin email
    final user = _auth.currentUser;
    if (user != null && user.email == 'admin@healmeal.com.bd') {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'role': 'admin',
        'name': 'Master Admin',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  static Map<String, dynamic> _encodeProduct(Product p) {
    return {
      'id': p.id,
      'name': p.name,
      'slug': p.slug,
      'brandName': p.brandName,
      'categorySlug': p.categorySlug,
      'mrp': p.mrp,
      'salePrice': p.salePrice,
      'discountPercent': p.discountPercent,
      'reviewCount': p.reviewCount,
      'rating': p.rating,
      'isRxRequired': p.isRxRequired,
      'isFlashSale': p.isFlashSale,
      'inStock': p.inStock,
      'imageUrl': p.imageUrl,
      'deliveryBadge': p.deliveryBadge,
      'gallery': p.gallery,
      'cashback': p.cashback,
      'stockLeft': p.stockLeft,
      'description': p.description,
      'howToUse': p.howToUse,
      'sideEffects': p.sideEffects,
      'storage': p.storage,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> _encodeLabTest(LabTest t) {
    return {
      'id': t.id,
      'name': t.name,
      'mrp': t.mrp,
      'salePrice': t.salePrice,
      'discountPercent': t.discountPercent,
      'reportHours': t.reportHours,
      'preparation': t.preparation,
      'imageUrl': t.imageUrl,
      'includes': t.includes,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

