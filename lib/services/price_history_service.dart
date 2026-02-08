import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class PriceHistoryService {
  static final PriceHistoryService _instance = PriceHistoryService._internal();
  factory PriceHistoryService() => _instance;
  PriceHistoryService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Track price change when product price is updated
  Future<void> trackPriceChange({
    required String productId,
    required int oldPrice,
    required int newPrice,
    String? reason,
  }) async {
    try {
      // Don't track if price hasn't changed
      if (oldPrice == newPrice) return;

      await _firestore
          .collection('products')
          .doc(productId)
          .collection('price_history')
          .add({
        'oldPrice': oldPrice,
        'newPrice': newPrice,
        'change': newPrice - oldPrice,
        'changePercent': ((newPrice - oldPrice) / oldPrice * 100).round(),
        'reason': reason ?? 'Price update',
        'timestamp': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Price history tracked for product $productId');
    } catch (e) {
      debugPrint('❌ Error tracking price history: $e');
    }
  }

  /// Get price history for a product
  Future<List<PriceHistoryEntry>> getPriceHistory(String productId, {int limit = 30}) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .doc(productId)
          .collection('price_history')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return PriceHistoryEntry(
          id: doc.id,
          oldPrice: data['oldPrice'] ?? 0,
          newPrice: data['newPrice'] ?? 0,
          change: data['change'] ?? 0,
          changePercent: data['changePercent'] ?? 0,
          reason: data['reason'] ?? '',
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting price history: $e');
      return [];
    }
  }

  /// Get price history stream for real-time updates
  Stream<List<PriceHistoryEntry>> getPriceHistoryStream(String productId, {int limit = 30}) {
    return _firestore
        .collection('products')
        .doc(productId)
        .collection('price_history')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return PriceHistoryEntry(
          id: doc.id,
          oldPrice: data['oldPrice'] ?? 0,
          newPrice: data['newPrice'] ?? 0,
          change: data['change'] ?? 0,
          changePercent: data['changePercent'] ?? 0,
          reason: data['reason'] ?? '',
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    });
  }

  /// Get current price vs lowest price in last 30 days
  Future<PriceSummary> getPriceSummary(String productId) async {
    try {
      final history = await getPriceHistory(productId);
      
      if (history.isEmpty) {
        return PriceSummary(
          currentPrice: 0,
          lowestPrice: 0,
          highestPrice: 0,
          averagePrice: 0,
          savingsPercent: 0,
        );
      }

      final currentPrice = history.first.newPrice;
      final allPrices = history.map((e) => e.newPrice).toList();
      
      final lowestPrice = allPrices.reduce((a, b) => a < b ? a : b);
      final highestPrice = allPrices.reduce((a, b) => a > b ? a : b);
      final averagePrice = (allPrices.reduce((a, b) => a + b) / allPrices.length).round();
      
      final savingsPercent = highestPrice > 0 
          ? ((highestPrice - currentPrice) / highestPrice * 100).round()
          : 0;

      return PriceSummary(
        currentPrice: currentPrice,
        lowestPrice: lowestPrice,
        highestPrice: highestPrice,
        averagePrice: averagePrice,
        savingsPercent: savingsPercent,
      );
    } catch (e) {
      debugPrint('❌ Error getting price summary: $e');
      return PriceSummary(
        currentPrice: 0,
        lowestPrice: 0,
        highestPrice: 0,
        averagePrice: 0,
        savingsPercent: 0,
      );
    }
  }
}

class PriceHistoryEntry {
  final String id;
  final int oldPrice;
  final int newPrice;
  final int change;
  final int changePercent;
  final String reason;
  final DateTime timestamp;

  PriceHistoryEntry({
    required this.id,
    required this.oldPrice,
    required this.newPrice,
    required this.change,
    required this.changePercent,
    required this.reason,
    required this.timestamp,
  });

  bool get isPriceIncrease => change > 0;
  bool get isPriceDecrease => change < 0;
}

class PriceSummary {
  final int currentPrice;
  final int lowestPrice;
  final int highestPrice;
  final int averagePrice;
  final int savingsPercent;

  PriceSummary({
    required this.currentPrice,
    required this.lowestPrice,
    required this.highestPrice,
    required this.averagePrice,
    required this.savingsPercent,
  });

  bool get isAtLowest => currentPrice == lowestPrice;
  bool get isGoodDeal => savingsPercent >= 10;
}
