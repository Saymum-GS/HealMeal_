import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<AppUser>> watchUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return AppUser(
          id: doc.id,
          name: data['name'] ?? 'Unknown User',
          phone: data['phone'] ?? '',
          role: data['role'] ?? 'patient',
          email: data['email'] ?? '',
          photoUrl: data['photoUrl'],
        );
      }).toList();
    });
  }

  Future<void> updateUserRole(String userId, String newRole) async {
    await _firestore.collection('users').doc(userId).update({'role': newRole});
  }

  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }
}
