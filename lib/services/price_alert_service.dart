import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PriceAlert {
  final String id;
  final String productId;
  final String productName;
  final double priceDropPercentage;
  final double originalPrice;
  final double newPrice;
  final DateTime alertTime;
  final bool isRead;

  PriceAlert({
    required this.id,
    required this.productId,
    required this.productName,
    required this.priceDropPercentage,
    required this.originalPrice,
    required this.newPrice,
    required this.alertTime,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'priceDropPercentage': priceDropPercentage,
      'originalPrice': originalPrice,
      'newPrice': newPrice,
      'alertTime': alertTime,
      'isRead': isRead,
    };
  }

  factory PriceAlert.fromMap(String id, Map<String, dynamic> map) {
    return PriceAlert(
      id: id,
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      priceDropPercentage: (map['priceDropPercentage'] ?? 0).toDouble(),
      originalPrice: (map['originalPrice'] ?? 0).toDouble(),
      newPrice: (map['newPrice'] ?? 0).toDouble(),
      alertTime: (map['alertTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
    );
  }
}

class PriceAlertService {
  static final PriceAlertService _instance = PriceAlertService._internal();
  factory PriceAlertService() => _instance;
  PriceAlertService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Track product for price alerts
  Future<void> trackProductForPriceAlert(
    String userId,
    String productId,
    String productName,
    double currentPrice,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tracked_products')
          .doc(productId)
          .set({
            'productId': productId,
            'productName': productName,
            'trackedPrice': currentPrice,
            'trackedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      debugPrint('✅ Product tracked for price alerts: $productName');
    } catch (e) {
      debugPrint('❌ Error tracking product: $e');
      rethrow;
    }
  }

  /// Remove product from price alerts
  Future<void> untrackProduct(String userId, String productId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('tracked_products')
          .doc(productId)
          .delete();
      debugPrint('✅ Product untracked from price alerts');
    } catch (e) {
      debugPrint('❌ Error untracking product: $e');
      rethrow;
    }
  }

  /// Get all price alerts for user
  Stream<List<PriceAlert>> getPriceAlerts(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('price_alerts')
        .orderBy('alertTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => PriceAlert.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  /// Get tracked products for user
  Stream<List<Map<String, dynamic>>> getTrackedProducts(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('tracked_products')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => doc.data()).toList();
        });
  }

  /// Create a price alert (called when price drop is detected)
  Future<void> createPriceAlert(
    String userId,
    String productId,
    String productName,
    double originalPrice,
    double newPrice,
  ) async {
    try {
      // Only create alert if price actually dropped
      if (newPrice >= originalPrice) {
        return;
      }

      final priceDrop = originalPrice - newPrice;
      final priceDropPercentage = (priceDrop / originalPrice * 100);

      final alert = PriceAlert(
        id: '',
        productId: productId,
        productName: productName,
        priceDropPercentage: priceDropPercentage,
        originalPrice: originalPrice,
        newPrice: newPrice,
        alertTime: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('price_alerts')
          .add(alert.toMap());

      debugPrint(
        '✅ Price alert created: $productName dropped ${priceDropPercentage.toStringAsFixed(1)}%',
      );
    } catch (e) {
      debugPrint('❌ Error creating price alert: $e');
      rethrow;
    }
  }

  /// Mark alert as read
  Future<void> markAlertAsRead(String userId, String alertId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('price_alerts')
          .doc(alertId)
          .update({'isRead': true});
    } catch (e) {
      debugPrint('❌ Error marking alert as read: $e');
      rethrow;
    }
  }

  /// Delete alert
  Future<void> deleteAlert(String userId, String alertId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('price_alerts')
          .doc(alertId)
          .delete();
    } catch (e) {
      debugPrint('❌ Error deleting alert: $e');
      rethrow;
    }
  }

  /// Get price alert settings for user
  Future<bool> isPriceAlertsEnabled(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notifications')
          .get();

      return doc.data()?['priceAlerts'] ?? true; // Enabled by default
    } catch (e) {
      debugPrint('❌ Error fetching price alert settings: $e');
      return true;
    }
  }

  /// Set price alert settings
  Future<void> setPriceAlertsEnabled(String userId, bool enabled) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('notifications')
          .set({'priceAlerts': enabled}, SetOptions(merge: true));
      debugPrint('Price alerts ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      debugPrint('❌ Error setting price alert settings: $e');
      rethrow;
    }
  }

  /// Track all products in the shop for price changes
  /// This watches all products and creates alerts when prices drop
  Future<void> trackAllProductsForPriceAlerts(
    String userId,
    List<Map<String, dynamic>> allProducts,
  ) async {
    try {
      // Get the reference prices collection for this user
      final priceRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('product_prices');

      // For each product, check if we have a stored price
      for (final productData in allProducts) {
        final productId = productData['id'] ?? '';
        final productName = productData['name'] ?? '';
        final currentPrice = (productData['price'] ?? 0).toDouble();

        if (productId.isEmpty) continue;

        // Get the stored reference price
        final storedDoc = await priceRef.doc(productId).get();

        if (storedDoc.exists) {
          // Compare with stored price
          final storedPrice = (storedDoc.data()?['price'] ?? 0).toDouble();

          if (currentPrice < storedPrice) {
            // Price dropped - create alert
            await createPriceAlert(
              userId,
              productId,
              productName,
              storedPrice,
              currentPrice,
            );
          }
        }

        // Update stored price
        await priceRef.doc(productId).set({
          'productId': productId,
          'productName': productName,
          'price': currentPrice,
          'lastChecked': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      debugPrint('✅ All products tracked for price changes');
    } catch (e) {
      debugPrint('❌ Error tracking all products: $e');
    }
  }

  /// Get all price drop alerts for user (not just from tracked items)
  Stream<List<PriceAlert>> getAllPriceAlerts(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('price_alerts')
        .orderBy('alertTime', descending: true)
        .limit(100) // Get last 100 alerts
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => PriceAlert.fromMap(doc.id, doc.data()))
              .toList();
        });
  }
}
