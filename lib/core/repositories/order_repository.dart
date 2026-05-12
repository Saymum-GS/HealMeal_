import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<AppOrder>> watchOrders() {
    return _firestore
        .collection('orders')
        .orderBy('placedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => AppOrder.fromMap(doc.data(), doc.id)).toList());
  }

  Stream<List<AppOrder>> watchRiderOrders() {
    return _firestore
        .collection('orders')
        .where('status', whereIn: [
          OrderStatus.dispatched.name, 
          OrderStatus.outForDelivery.name, 
          OrderStatus.delivered.name
        ])
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => AppOrder.fromMap(doc.data(), doc.id)).toList());
  }
  
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status.name,
    });
  }

  Future<void> assignRider(String orderId, AppUser rider) async {
    await _firestore.collection('orders').doc(orderId).update({
      'rider': {
        'name': rider.name,
        'phone': rider.phone,
        'rating': 4.8, // Default rating for now
      },
      'status': OrderStatus.confirmed.name,
    });
  }
}
