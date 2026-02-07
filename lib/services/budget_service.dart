import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class BudgetService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Save budget settings
  static Future<void> saveBudget({
    required double monthlyLimit,
    required double weeklyLimit,
    required bool enableNotifications,
    required double notificationThreshold, // Percentage (e.g., 80 for 80%)
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('budgets').doc(user.uid).set({
        'monthlyLimit': monthlyLimit,
        'weeklyLimit': weeklyLimit,
        'enableNotifications': enableNotifications,
        'notificationThreshold': notificationThreshold,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving budget: $e');
      rethrow;
    }
  }

  /// Get budget settings
  static Future<Map<String, dynamic>?> getBudget() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('budgets').doc(user.uid).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      debugPrint('Error getting budget: $e');
      return null;
    }
  }

  /// Get budget as stream
  static Stream<DocumentSnapshot> getBudgetStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _firestore.collection('budgets').doc(user.uid).snapshots();
  }

  /// Calculate spending for a period
  static Future<double> calculateSpending({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return 0.0;

    try {
      final orders = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .where(
            'createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      double total = 0;
      for (var doc in orders.docs) {
        final data = doc.data();
        total += ((data['total'] ?? 0) / 100);
      }
      return total;
    } catch (e) {
      debugPrint('Error calculating spending: $e');
      return 0.0;
    }
  }

  /// Get this week's spending
  static Future<double> getWeeklySpending() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return calculateSpending(startDate: startDate, endDate: endDate);
  }

  /// Get this month's spending
  static Future<double> getMonthlySpending() async {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return calculateSpending(startDate: startDate, endDate: endDate);
  }

  /// Check if budget limit is reached
  static Future<Map<String, dynamic>> checkBudgetStatus() async {
    final budget = await getBudget();
    if (budget == null) {
      return {
        'hasMonthlyLimit': false,
        'hasWeeklyLimit': false,
        'monthlyPercentage': 0.0,
        'weeklyPercentage': 0.0,
      };
    }

    final monthlyLimit = budget['monthlyLimit'] ?? 0.0;
    final weeklyLimit = budget['weeklyLimit'] ?? 0.0;

    final monthlySpending = await getMonthlySpending();
    final weeklySpending = await getWeeklySpending();

    return {
      'hasMonthlyLimit': monthlyLimit > 0,
      'hasWeeklyLimit': weeklyLimit > 0,
      'monthlyLimit': monthlyLimit,
      'weeklyLimit': weeklyLimit,
      'monthlySpending': monthlySpending,
      'weeklySpending': weeklySpending,
      'monthlyPercentage': monthlyLimit > 0
          ? (monthlySpending / monthlyLimit * 100)
          : 0.0,
      'weeklyPercentage': weeklyLimit > 0
          ? (weeklySpending / weeklyLimit * 100)
          : 0.0,
      'monthlyExceeded': monthlyLimit > 0 && monthlySpending > monthlyLimit,
      'weeklyExceeded': weeklyLimit > 0 && weeklySpending > weeklyLimit,
      'enableNotifications': budget['enableNotifications'] ?? false,
      'notificationThreshold': budget['notificationThreshold'] ?? 80.0,
    };
  }
}
