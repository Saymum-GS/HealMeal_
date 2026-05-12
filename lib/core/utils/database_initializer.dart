import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models.dart';
import '../data/sample_products.dart';

class DatabaseInitializer {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> seedDatabase() async {
    // 1. Wipe existing data
    final productDocs = await _firestore.collection('products').get();
    for (var doc in productDocs.docs) {
      await doc.reference.delete();
    }
    
    final categoryDocs = await _firestore.collection('categories').get();
    for (var doc in categoryDocs.docs) {
      await doc.reference.delete();
    }

    // 2. Seed Categories
    final categories = {
      'medicine': 'Medicines',
      'healthcare': 'Healthcare',
      'supplement': 'Supplements',
      'babyMomCare': 'Baby & Mom Care',
      'petCare': 'Pet Care',
      'diabeticCare': 'Diabetic Care',
      'cardiacCare': 'Cardiac Care',
    };

    for (var entry in categories.entries) {
      await _firestore.collection('categories').doc(entry.key).set({
        'name': entry.value,
        'slug': entry.key,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // 2. Seed Products
    for (var product in sampleProducts) {
      await _firestore.collection('products').doc(product.id).set(product.toMap());
    }

    print('Database seeded with ${categories.length} categories and ${sampleProducts.length} products.');
  }

  static Future<void> seedDatabaseIfEmpty() async {
    final snapshot = await _firestore.collection('products').limit(1).get();
    if (snapshot.docs.isEmpty) {
      await seedDatabase();
    }
  }
}
