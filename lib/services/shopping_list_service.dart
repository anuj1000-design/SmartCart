import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

class ShoppingListService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Add product to shopping list
  Future<void> addToList(Product product) async {
    if (_userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('shopping_lists')
        .doc(_userId)
        .collection('items')
        .doc(product.id)
        .set({
      'productId': product.id,
      'productName': product.name,
      'productEmoji': product.imageEmoji,
      'price': product.price,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // Remove from shopping list
  Future<void> removeFromList(String productId) async {
    if (_userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('shopping_lists')
        .doc(_userId)
        .collection('items')
        .doc(productId)
        .delete();
  }

  // Check if product is in list
  Future<bool> isInList(String productId) async {
    if (_userId == null) return false;

    final doc = await _firestore
        .collection('shopping_lists')
        .doc(_userId)
        .collection('items')
        .doc(productId)
        .get();

    return doc.exists;
  }

  // Get shopping list stream
  Stream<List<String>> getShoppingListStream() {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('shopping_lists')
        .doc(_userId)
        .collection('items')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  // Clear entire shopping list
  Future<void> clearList() async {
    if (_userId == null) throw Exception('User not authenticated');

    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('shopping_lists')
        .doc(_userId)
        .collection('items')
        .get();

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Move all items from shopping list to cart
  Future<List<String>> moveAllToCart() async {
    if (_userId == null) throw Exception('User not authenticated');

    final snapshot = await _firestore
        .collection('shopping_lists')
        .doc(_userId)
        .collection('items')
        .get();

    final productIds = snapshot.docs.map((doc) => doc.id).toList();
    await clearList();
    return productIds;
  }
}
