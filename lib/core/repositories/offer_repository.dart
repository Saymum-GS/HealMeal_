import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models.dart';

class OfferRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<AppOffer>> watchOffers() {
    return _firestore.collection('offers').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => AppOffer.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<void> addOffer(AppOffer offer) async {
    await _firestore.collection('offers').doc(offer.id).set(offer.toMap());
  }

  Future<void> updateOffer(AppOffer offer) async {
    await _firestore.collection('offers').doc(offer.id).update(offer.toMap());
  }

  Future<void> deleteOffer(String id) async {
    await _firestore.collection('offers').doc(id).delete();
  }
}
