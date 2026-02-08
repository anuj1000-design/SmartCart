import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecentlyViewedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Track product view
  Future<void> trackView(String productId) async {
    if (_userId == null) return;

    await _firestore
        .collection('recently_viewed')
        .doc(_userId)
        .collection('products')
        .doc(productId)
        .set({
      'productId': productId,
      'viewedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Get recently viewed product IDs
  Future<List<String>> getRecentlyViewed({int limit = 20}) async {
    if (_userId == null) return [];

    final snapshot = await _firestore
        .collection('recently_viewed')
        .doc(_userId)
        .collection('products')
        .orderBy('viewedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // Clear recently viewed
  Future<void> clearHistory() async {
    if (_userId == null) return;

    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('recently_viewed')
        .doc(_userId)
        .collection('products')
        .get();

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
