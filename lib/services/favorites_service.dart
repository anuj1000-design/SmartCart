import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class FavoritesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add item to favorites
  static Future<void> addToFavorites(Map<String, dynamic> product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('favorites')
          .doc(user.uid)
          .collection('items')
          .doc(product['barcode'] ?? product['name'])
          .set({...product, 'addedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      debugPrint('Error adding to favorites: $e');
      rethrow;
    }
  }

  /// Remove item from favorites
  static Future<void> removeFromFavorites(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('favorites')
          .doc(user.uid)
          .collection('items')
          .doc(productId)
          .delete();
    } catch (e) {
      debugPrint('Error removing from favorites: $e');
      rethrow;
    }
  }

  /// Check if item is in favorites
  static Future<bool> isFavorite(String productId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final doc = await _firestore
          .collection('favorites')
          .doc(user.uid)
          .collection('items')
          .doc(productId)
          .get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking favorite: $e');
      return false;
    }
  }

  /// Get all favorites
  static Stream<QuerySnapshot> getFavorites() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('favorites')
        .doc(user.uid)
        .collection('items')
        .orderBy('addedAt', descending: true)
        .snapshots();
  }

  /// Toggle favorite status
  static Future<bool> toggleFavorite(Map<String, dynamic> product) async {
    final productId = product['barcode'] ?? product['name'];
    final isFav = await isFavorite(productId);

    if (isFav) {
      await removeFromFavorites(productId);
      return false;
    } else {
      await addToFavorites(product);
      return true;
    }
  }
}
