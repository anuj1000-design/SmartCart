import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoyaltyProgramService {
  static final LoyaltyProgramService _instance = LoyaltyProgramService._internal();
  factory LoyaltyProgramService() => _instance;
  LoyaltyProgramService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get loyalty program settings
  Future<LoyaltySettings> getSettings() async {
    try {
      final doc = await _firestore.collection('settings').doc('loyalty_program').get();
      if (doc.exists) {
        final data = doc.data()!;
        return LoyaltySettings(
          pointsPer100: data['pointsPer100'] ?? 10,
          pointsValue: data['pointsValue'] ?? 100, // paise per point
          minPointsRedeem: data['minPointsRedeem'] ?? 100,
          signupBonus: data['signupBonus'] ?? 50,
        );
      }
      return LoyaltySettings();
    } catch (e) {
      print('Error getting loyalty settings: $e');
      return LoyaltySettings();
    }
  }

  /// Get user's loyalty points
  Future<int> getUserPoints() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return 0;

      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data()?['loyaltyPoints'] ?? 0;
    } catch (e) {
      print('Error getting user points: $e');
      return 0;
    }
  }

  /// Get user's loyalty points stream
  Stream<int> getUserPointsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(0);

    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      return doc.data()?['loyaltyPoints'] ?? 0;
    });
  }

  /// Award points for order
  Future<void> awardPointsForOrder(int orderTotal) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final settings = await getSettings();
      final pointsToAward = (orderTotal / 10000 * settings.pointsPer100).floor();

      await _firestore.collection('users').doc(userId).update({
        'loyaltyPoints': FieldValue.increment(pointsToAward),
      });

      // Track transaction
      await _firestore.collection('users').doc(userId).collection('loyalty_transactions').add({
        'type': 'earn',
        'points': pointsToAward,
        'orderTotal': orderTotal,
        'description': 'Points earned from order',
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('✅ Awarded $pointsToAward points');
    } catch (e) {
      print('❌ Error awarding points: $e');
    }
  }

  /// Redeem points for discount
  Future<int> redeemPoints(int pointsToRedeem) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return 0;

      final settings = await getSettings();
      final currentPoints = await getUserPoints();

      if (pointsToRedeem < settings.minPointsRedeem) {
        throw Exception('Minimum ${settings.minPointsRedeem} points required');
      }

      if (pointsToRedeem > currentPoints) {
        throw Exception('Insufficient points');
      }

      // Calculate discount value
      final discountValue = pointsToRedeem * settings.pointsValue;

      // Deduct points
      await _firestore.collection('users').doc(userId).update({
        'loyaltyPoints': FieldValue.increment(-pointsToRedeem),
      });

      // Track transaction
      await _firestore.collection('users').doc(userId).collection('loyalty_transactions').add({
        'type': 'redeem',
        'points': -pointsToRedeem,
        'discountValue': discountValue,
        'description': 'Points redeemed for discount',
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('✅ Redeemed $pointsToRedeem points for ₹${(discountValue / 100).toStringAsFixed(2)}');
      return discountValue;
    } catch (e) {
      print('❌ Error redeeming points: $e');
      rethrow;
    }
  }

  /// Get loyalty transaction history
  Future<List<LoyaltyTransaction>> getTransactionHistory({int limit = 20}) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return [];

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('loyalty_transactions')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return LoyaltyTransaction(
          id: doc.id,
          type: data['type'] ?? '',
          points: data['points'] ?? 0,
          description: data['description'] ?? '',
          timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          orderTotal: data['orderTotal'],
          discountValue: data['discountValue'],
        );
      }).toList();
    } catch (e) {
      print('Error getting transaction history: $e');
      return [];
    }
  }

  /// Calculate points for amount
  int calculatePointsForAmount(int amount) {
    return (amount / 10000 * 10).floor(); // Default 10 points per 100 rupees
  }

  /// Calculate discount for points
  int calculateDiscountForPoints(int points) {
    return points * 100; // Default 1 point = 1 rupee
  }
}

class LoyaltySettings {
  final int pointsPer100;
  final int pointsValue;
  final int minPointsRedeem;
  final int signupBonus;

  LoyaltySettings({
    this.pointsPer100 = 10,
    this.pointsValue = 100,
    this.minPointsRedeem = 100,
    this.signupBonus = 50,
  });
}

class LoyaltyTransaction {
  final String id;
  final String type;
  final int points;
  final String description;
  final DateTime timestamp;
  final int? orderTotal;
  final int? discountValue;

  LoyaltyTransaction({
    required this.id,
    required this.type,
    required this.points,
    required this.description,
    required this.timestamp,
    this.orderTotal,
    this.discountValue,
  });

  bool get isEarned => type == 'earn';
  bool get isRedeemed => type == 'redeem';
}
