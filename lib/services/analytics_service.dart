import 'package:cloud_firestore/cloud_firestore.dart' as cloud;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();

  factory AnalyticsService() {
    return _instance;
  }

  AnalyticsService._internal();

  final db = cloud.FirebaseFirestore.instance;
  late final FirebaseAnalytics _analytics;
  late final FirebaseCrashlytics _crashlytics;

  /// Initialize Firebase Analytics and Crashlytics
  Future<void> initialize() async {
    try {
      _analytics = FirebaseAnalytics.instance;
      _crashlytics = FirebaseCrashlytics.instance;

      // Enable crash reporting in non-debug mode
      await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

      // Record app open event
      await logAppOpen();

      debugPrint('Analytics service initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize analytics: $e');
      recordError(e, StackTrace.current, reason: 'initialize');
    }
  }

  /// Log app open event
  Future<void> logAppOpen() async {
    try {
      await _analytics.logAppOpen();
    } catch (e) {
      recordError(e, StackTrace.current, reason: 'logAppOpen');
    }
  }

  /// Log user login event
  Future<void> logLogin({required String method}) async {
    try {
      await _analytics.logLogin(loginMethod: method);
      await _analytics.logEvent(
        name: 'user_login',
        parameters: {'method': method},
      );
    } catch (e) {
      recordError(e, StackTrace.current, reason: 'logLogin');
    }
  }

  /// Log user signup event
  Future<void> logSignUp({required String method}) async {
    try {
      await _analytics.logSignUp(signUpMethod: method);
      await _analytics.logEvent(
        name: 'user_signup',
        parameters: {'method': method},
      );
    } catch (e) {
      recordError(e, StackTrace.current, reason: 'logSignUp');
    }
  }

  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    } catch (e) {
      recordError(e, StackTrace.current, reason: 'logScreenView');
    }
  }

  /// Set user ID for analytics
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (e) {
      recordError(e, StackTrace.current, reason: 'setUserId');
    }
  }

  /// Record error for crash reporting
  void recordError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
  }) {
    try {
      _crashlytics.recordError(error, stackTrace, reason: reason, fatal: fatal);
    } catch (e) {
      debugPrint('Failed to record error: $e');
    }
  }

  /// Record Flutter error
  void recordFlutterError(FlutterErrorDetails details) {
    try {
      _crashlytics.recordFlutterError(details);
    } catch (e) {
      debugPrint('Failed to record Flutter error: $e');
    }
  }

  /// Log non-fatal error
  void logError(
    String message, {
    String? errorCode,
    Map<String, dynamic>? parameters,
  }) {
    try {
      _crashlytics.log(message);
      if (errorCode != null) {
        _crashlytics.setCustomKey('error_code', errorCode);
      }
      if (parameters != null) {
        parameters.forEach((key, value) {
          _crashlytics.setCustomKey(key, value.toString());
        });
      }
    } catch (e) {
      debugPrint('Failed to log error: $e');
    }
  }

  /// Log custom event
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      // Convert booleans to strings for Firebase Analytics compatibility
      final convertedParams = parameters?.map((key, value) {
        if (value is bool) {
          return MapEntry(key, value.toString());
        }
        return MapEntry(key, value);
      });

      await _analytics.logEvent(
        name: name,
        parameters: convertedParams?.cast<String, Object>(),
      );
    } catch (e) {
      recordError(e, StackTrace.current, reason: 'logEvent');
    }
  }

  // Track product view
  Future<void> trackProductView(
    String productId,
    String productName, {
    String? category,
  }) async {
    try {
      // Firestore tracking
      await db.collection('analytics/products/views').add({
        'productId': productId,
        'productName': productName,
        'timestamp': cloud.FieldValue.serverTimestamp(),
        'type': 'view',
      });

      // Update product popularity counter
      await db
          .collection('products')
          .doc(productId)
          .update({'viewCount': cloud.FieldValue.increment(1)})
          .catchError((_) => null); // Ignore if product doesn't exist

      // Firebase Analytics tracking
      await logProductView(
        productId: productId,
        productName: productName,
        category: category ?? 'Unknown',
      );
    } catch (e) {
      debugPrint('Error tracking product view: $e');
      recordError(e, StackTrace.current, reason: 'trackProductView');
    }
  }

  /// Log product view to Firebase Analytics
  Future<void> logProductView({
    required String productId,
    required String productName,
    required String category,
  }) async {
    try {
      await _analytics.logViewItem(
        items: [
          AnalyticsEventItem(
            itemId: productId,
            itemName: productName,
            itemCategory: category,
          ),
        ],
      );
    } catch (e) {
      recordError(e, StackTrace.current, reason: 'logProductView');
    }
  }

  // Track add to cart
  Future<void> trackAddToCart(
    String productId,
    String productName, {
    String? category,
    int quantity = 1,
    double? price,
  }) async {
    try {
      // Firestore tracking
      await db.collection('analytics/products/carts').add({
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'price': price,
        'timestamp': cloud.FieldValue.serverTimestamp(),
        'type': 'cart',
      });

      await db
          .collection('products')
          .doc(productId)
          .update({'cartCount': cloud.FieldValue.increment(quantity)})
          .catchError((_) => null);

      // Firebase Analytics tracking
      await logAddToCart(
        productId: productId,
        productName: productName,
        category: category ?? 'Unknown',
        quantity: quantity,
        price: price ?? 0.0,
      );
    } catch (e) {
      debugPrint('Error tracking add to cart: $e');
      recordError(e, StackTrace.current, reason: '');
    }
  }

  /// Log add to cart to Firebase Analytics
  Future<void> logAddToCart({
    required String productId,
    required String productName,
    required String category,
    required int quantity,
    required double price,
  }) async {
    try {
      await _analytics.logAddToCart(
        items: [
          AnalyticsEventItem(
            itemId: productId,
            itemName: productName,
            itemCategory: category,
            quantity: quantity,
            price: price,
          ),
        ],
      );
    } catch (e) {
      recordError(e, StackTrace.current, reason: '');
    }
  }

  // Track purchase
  Future<void> trackPurchase(
    String productId,
    String productName,
    int quantity,
    int price, {
    String? category,
    String? transactionId,
  }) async {
    try {
      // Firestore tracking
      await db.collection('analytics/products/purchases').add({
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'price': price,
        'transactionId': transactionId,
        'timestamp': cloud.FieldValue.serverTimestamp(),
        'type': 'purchase',
      });

      await db
          .collection('products')
          .doc(productId)
          .update({
            'purchaseCount': cloud.FieldValue.increment(quantity),
            'revenue': cloud.FieldValue.increment(price * quantity),
          })
          .catchError((_) => null);

      // Firebase Analytics tracking
      await logPurchase(
        transactionId: transactionId ?? 'unknown',
        total: (price * quantity).toDouble(),
        items: [
          {
            'id': productId,
            'name': productName,
            'category': category ?? 'Unknown',
            'quantity': quantity,
            'price': price.toDouble(),
          },
        ],
      );
    } catch (e) {
      debugPrint('Error tracking purchase: $e');
      recordError(e, StackTrace.current, reason: '');
    }
  }

  /// Log purchase to Firebase Analytics
  Future<void> logPurchase({
    required String transactionId,
    required double total,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final analyticsItems = items
          .map(
            (item) => AnalyticsEventItem(
              itemId: item['id'],
              itemName: item['name'],
              itemCategory: item['category'],
              quantity: item['quantity'],
              price: item['price'],
            ),
          )
          .toList();

      await _analytics.logPurchase(
        transactionId: transactionId,
        value: total,
        currency: 'INR',
        items: analyticsItems,
      );
    } catch (e) {
      recordError(e, StackTrace.current, reason: '');
    }
  }

  // Track search
  Future<void> trackSearch(String query) async {
    try {
      // Firestore tracking
      await db.collection('analytics/searches').add({
        'query': query,
        'timestamp': cloud.FieldValue.serverTimestamp(),
      });

      // Firebase Analytics tracking
      await _analytics.logSearch(searchTerm: query);
    } catch (e) {
      debugPrint('Error tracking search: $e');
      recordError(e, StackTrace.current, reason: '');
    }
  }

  // Get popular products
  Future<List<Map<String, dynamic>>> getPopularProducts() async {
    try {
      final snapshot = await db
          .collection('products')
          .orderBy('viewCount', descending: true)
          .limit(10)
          .get();

      return snapshot.docs
          .map(
            (doc) => {
              'id': doc.id,
              'name': doc['name'] ?? 'Unknown',
              'views': doc['viewCount'] ?? 0,
              'carts': doc['cartCount'] ?? 0,
              'purchases': doc['purchaseCount'] ?? 0,
              'revenue': doc['revenue'] ?? 0,
            },
          )
          .toList();
    } catch (e) {
      debugPrint('Error getting popular products: $e');
      return [];
    }
  }

  // Get total stats
  Future<Map<String, dynamic>> getTotalStats() async {
    try {
      final viewsSnap = await db
          .collection('analytics/products/views')
          .count()
          .get();
      final cartsSnap = await db
          .collection('analytics/products/carts')
          .count()
          .get();
      final purchasesSnap = await db
          .collection('analytics/products/purchases')
          .count()
          .get();
      final searchesSnap = await db
          .collection('analytics/searches')
          .count()
          .get();

      return {
        'totalViews': viewsSnap.count,
        'totalCarts': cartsSnap.count,
        'totalPurchases': purchasesSnap.count,
        'totalSearches': searchesSnap.count,
      };
    } catch (e) {
      debugPrint('Error getting total stats: $e');
      return {
        'totalViews': 0,
        'totalCarts': 0,
        'totalPurchases': 0,
        'totalSearches': 0,
      };
    }
  }

  // Get trending searches
  Future<List<Map<String, dynamic>>> getTrendingSearches() async {
    try {
      final snapshot = await db
          .collection('analytics/searches')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();

      final searchMap = <String, int>{};
      for (var doc in snapshot.docs) {
        final query = doc['query'] as String;
        searchMap[query] = (searchMap[query] ?? 0) + 1;
      }

      return searchMap.entries
          .map((e) => {'query': e.key, 'count': e.value})
          .toList()
        ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    } catch (e) {
      debugPrint('Error getting trending searches: $e');
      return [];
    }
  }
}
