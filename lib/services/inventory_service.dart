import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';

/// Inventory Management Service
/// Handles stock validation, low stock alerts, and inventory reconciliation
class InventoryService {
  static const int lowStockThreshold = 10; // Alert when stock < 10
  static const String alertsCollection = 'inventory_alerts';
  static const String historyCollection = 'stock_history';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check if product has sufficient stock
  bool hasStock(int availableStock, int requiredQuantity) {
    return availableStock >= requiredQuantity;
  }

  /// Get stock status with details
  Map<String, dynamic> getStockStatus(int currentStock) {
    final isLowStock = currentStock < lowStockThreshold;
    final isCritical = currentStock < 5;
    final isEmpty = currentStock <= 0;

    return {
      'isLowStock': isLowStock,
      'isCritical': isCritical,
      'isEmpty': isEmpty,
      'status': isEmpty
          ? '🔴 Out of Stock'
          : isCritical
          ? '🟠 Critical'
          : isLowStock
          ? '🟡 Low'
          : '🟢 Good',
    };
  }

  /// Send low stock notification to admins
  Future<void> notifyLowStock(
    String productId,
    String productName,
    int currentStock,
  ) async {
    try {
      final status = getStockStatus(currentStock);

      // Only alert if low or critical
      if (status['isLowStock'] != true) return;

      final alertId = 'ALERT_${DateTime.now().millisecondsSinceEpoch}';

      await _firestore.collection(alertsCollection).doc(alertId).set({
        'id': alertId,
        'productId': productId,
        'productName': productName,
        'currentStock': currentStock,
        'threshold': lowStockThreshold,
        'severity': status['isCritical'] ? 'CRITICAL' : 'WARNING',
        'status': status['status'],
        'createdAt': FieldValue.serverTimestamp(),
        'resolved': false,
      });

      debugPrint(
        '🚨 Low Stock Alert: $productName ($currentStock units) - ${status['status']}',
      );
    } catch (e) {
      debugPrint('❌ Error creating low stock alert: $e');
    }
  }

  /// Log stock transaction for audit trail
  Future<void> logStockTransaction(
    String productId,
    String productName,
    int quantityChange,
    String reason,
  ) async {
    try {
      final historyId = 'HIST_${DateTime.now().millisecondsSinceEpoch}';

      await _firestore.collection(historyCollection).doc(historyId).set({
        'id': historyId,
        'productId': productId,
        'productName': productName,
        'quantityChange': quantityChange,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      });

      debugPrint(
        '📊 Stock Transaction: $productName ${quantityChange > 0 ? '+' : ''}$quantityChange ($reason)',
      );
    } catch (e) {
      debugPrint('❌ Error logging stock transaction: $e');
    }
  }

  /// Recalculate inventory based on orders
  /// Compares product stock with sum of all orders for that product
  Future<Map<String, dynamic>> recalculateInventory() async {
    try {
      debugPrint('🔄 Starting inventory recalculation...');

      final results = {
        'scanned': 0,
        'discrepancies': 0,
        'fixed': 0,
        'errors': <String>[],
      };

      // Get all products
      final productsSnap = await _firestore.collection('products').get();
      results['scanned'] = productsSnap.docs.length;

      final batch = _firestore.batch();

      for (var productDoc in productsSnap.docs) {
        final productId = productDoc.id;
        final productData = productDoc.data();
        final currentStock = (productData['stockQuantity'] ?? 0).toInt();
        final productName = productData['name'] ?? 'Unknown';

        // Get all orders with this product
        final ordersSnap = await _firestore
            .collection('orders')
            .where('items', arrayContains: {'productId': productId})
            .get();

        int totalSold = 0;
        for (var orderDoc in ordersSnap.docs) {
          final items = orderDoc['items'] as List<dynamic>? ?? [];
          for (var item in items) {
            if (item is Map && item['productId'] == productId) {
              totalSold += ((item['quantity'] ?? 0) as num).toInt();
            }
          }
        }

        // Calculate expected stock (initial stock - sold)
        // Note: This assumes you have initial_stock field. If not, use current stock.
        final initialStock = (productData['initial_stock'] ?? currentStock)
            .toInt();
        final expectedStock = (initialStock - totalSold)
            .clamp(0, double.infinity)
            .toInt();

        // Check for discrepancy
        if (currentStock != expectedStock) {
          debugPrint(
            '⚠️  Discrepancy found: $productName - Current: $currentStock, Expected: $expectedStock',
          );

          final discrepancies = results['discrepancies'] as int? ?? 0;
          results['discrepancies'] = discrepancies + 1;

          // Fix the stock
          batch.update(productDoc.reference, {
            'stockQuantity': expectedStock,
            'lastRecalculated': FieldValue.serverTimestamp(),
            'previousStock': currentStock,
          });

          final fixed = results['fixed'] as int? ?? 0;
          results['fixed'] = fixed + 1;

          // Log this correction
          await logStockTransaction(
            productId,
            productName,
            expectedStock - currentStock,
            'Inventory Recalculation',
          );
        }
      }

      await batch.commit();

      debugPrint(
        '✅ Inventory recalculation complete: ${results['fixed']} discrepancies fixed!',
      );

      return results;
    } catch (e) {
      debugPrint('❌ Error recalculating inventory: $e');
      return {'error': e.toString()};
    }
  }

  /// Monitor stock for all products and send alerts
  Future<void> monitorAllStock() async {
    try {
      final snapshot = await _firestore.collection('products').get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final stock = (data['stockQuantity'] ?? 0).toInt();
        final name = data['name'] ?? 'Unknown';
        final productId = doc.id;

        // Check stock and notify if low
        if (stock < lowStockThreshold) {
          await notifyLowStock(productId, name, stock);
        }
      }

      debugPrint('✅ Stock monitoring complete!');
    } catch (e) {
      debugPrint('❌ Error monitoring stock: $e');
    }
  }

  /// Get all active low stock alerts
  Stream<QuerySnapshot> getLowStockAlerts() {
    return _firestore
        .collection(alertsCollection)
        .where('resolved', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Get stock history for a product
  Stream<QuerySnapshot> getStockHistory(String productId) {
    return _firestore
        .collection(historyCollection)
        .where('productId', isEqualTo: productId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();
  }

  /// Resolve a low stock alert (mark as handled)
  Future<void> resolveAlert(String alertId, {String note = ''}) async {
    try {
      await _firestore.collection(alertsCollection).doc(alertId).update({
        'resolved': true,
        'resolvedAt': FieldValue.serverTimestamp(),
        'note': note,
      });

      debugPrint('✅ Alert $alertId resolved');
    } catch (e) {
      debugPrint('❌ Error resolving alert: $e');
    }
  }

  /// Get inventory statistics
  Future<Map<String, dynamic>> getInventoryStats() async {
    try {
      final snapshot = await _firestore.collection('products').get();

      int totalItems = 0;
      int lowStockCount = 0;
      int criticalCount = 0;
      int outOfStockCount = 0;

      for (var doc in snapshot.docs) {
        final stock = ((doc['stockQuantity'] ?? 0) as num).toInt();
        totalItems += stock;

        if (stock <= 0) {
          outOfStockCount++;
        } else if (stock < 5) {
          criticalCount++;
        } else if (stock < lowStockThreshold) {
          lowStockCount++;
        }
      }

      return {
        'totalProducts': snapshot.docs.length,
        'totalItems': totalItems,
        'lowStockCount': lowStockCount,
        'criticalCount': criticalCount,
        'outOfStockCount': outOfStockCount,
        'healthPercentage': snapshot.docs.isEmpty
            ? 0
            : ((snapshot.docs.length - outOfStockCount - criticalCount) /
                      snapshot.docs.length *
                      100)
                  .toStringAsFixed(1),
      };
    } catch (e) {
      debugPrint('❌ Error getting inventory stats: $e');
      return {'error': e.toString()};
    }
  }

  /// Get products with low stock (less than threshold)
  Future<List<Product>> getLowStockProducts() async {
    try {
      final querySnapshot = await _firestore
          .collection('products')
          .where('stockQuantity', isLessThan: lowStockThreshold)
          .where('stockQuantity', isGreaterThan: 0)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Product(
          id: doc.id,
          name: data['name'] ?? '',
          category: data['category'] ?? 'other',
          brand: data['brand'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] ?? 0).toDouble().toInt(),
          barcode: data['barcode'] ?? '',
          imageEmoji: data['imageEmoji'] ?? '📦',
          color: data['color'] ?? Colors.grey.shade800,
          stockQuantity: (data['stockQuantity'] ?? 0).toInt(),
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting low stock products: $e');
      return [];
    }
  }

  /// Get recommended products based on cart items
  Future<List<Product>> getRecommendedProducts(List<CartItem> cartItems) async {
    try {
      if (cartItems.isEmpty) {
        // Return popular products if cart is empty
        final querySnapshot = await _firestore
            .collection('products')
            .where('stockQuantity', isGreaterThan: 0)
            .limit(6)
            .get();

        return querySnapshot.docs.map((doc) {
          final data = doc.data();
          return Product(
            id: doc.id,
            name: data['name'] ?? '',
            category: data['category'] ?? 'other',
            brand: data['brand'] ?? '',
            description: data['description'] ?? '',
            price: (data['price'] ?? 0).toDouble().toInt(),
            barcode: data['barcode'] ?? '',
            imageEmoji: data['imageEmoji'] ?? '📦',
            color: data['color'] ?? Colors.grey.shade800,
            stockQuantity: (data['stockQuantity'] ?? 0).toInt(),
          );
        }).toList();
      }

      // Get categories from cart items
      final categories = cartItems.map((item) => item.product.category).toSet();

      // Find products in same categories (without stockQuantity filter to avoid index requirement)
      final querySnapshot = await _firestore
          .collection('products')
          .where('category', whereIn: categories.toList())
          .limit(20)
          .get();

      // Filter out products already in cart and filter by stock in code
      final cartProductIds = cartItems.map((item) => item.product.id).toSet();
      final recommendations = querySnapshot.docs
          .where((doc) {
            final stockQuantity = (doc['stockQuantity'] ?? 0) as int;
            return !cartProductIds.contains(doc.id) && stockQuantity > 0;
          })
          .take(6)
          .map((doc) {
            final data = doc.data();
            return Product(
              id: doc.id,
              name: data['name'] ?? '',
              category: data['category'] ?? 'other',
              brand: data['brand'] ?? '',
              description: data['description'] ?? '',
              price: (data['price'] ?? 0).toDouble().toInt(),
              barcode: data['barcode'] ?? '',
              imageEmoji: data['imageEmoji'] ?? '📦',
              color: data['color'] ?? Colors.grey.shade800,
              stockQuantity: (data['stockQuantity'] ?? 0).toInt(),
            );
          })
          .toList();

      return recommendations;
    } catch (e) {
      debugPrint('❌ Error getting recommended products: $e');
      return [];
    }
  }
}
