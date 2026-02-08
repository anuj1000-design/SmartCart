import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    debugPrint('User notification permission: ${settings.authorizationStatus}');

    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    debugPrint('🔔 FCM Token: $token');

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📬 Foreground message: ${message.notification?.title}');
      _showLocalNotification(
        title: message.notification?.title ?? 'SmartCart',
        body: message.notification?.body ?? 'New notification',
        payload: message.data,
      );
    });

    // Handle background message tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📭 Message opened: ${message.notification?.title}');
      _handleNotificationTap(message.data);
    });
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'smartcart_channel',
          'SmartCart Notifications',
          channelDescription: 'Notifications for SmartCart orders and alerts',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      details,
      payload: payload?.toString(),
    );
  }

  void _handleNotificationTap(Map<String, dynamic> payload) {
    debugPrint('🎯 Notification tapped with payload: $payload');
    // Handle navigation based on notification type
    if (payload.containsKey('type')) {
      final type = payload['type'];
      if (type == 'order_confirmed' || type == 'order_shipped') {
        debugPrint('📋 Navigate to orders');
      } else if (type == 'stock_alert') {
        debugPrint('📊 Navigate to admin');
      }
    }
  }

  // Send order confirmation notification
  Future<void> sendOrderConfirmedNotification({
    required String userId,
    required String orderId,
    required int total,
  }) async {
    try {
      _showLocalNotification(
        title: '✅ Order Confirmed',
        body:
            'Your order #${orderId.substring(0, 8)} for ₹${(total / 100).toStringAsFixed(2)} is confirmed!',
        payload: {
          'type': 'order_confirmed',
          'orderId': orderId,
          'userId': userId,
        },
      );
      debugPrint('✅ Order confirmation notification sent');
    } catch (e) {
      debugPrint('❌ Error sending order notification: $e');
    }
  }

  // Send order shipped notification
  Future<void> sendOrderShippedNotification({
    required String userId,
    required String orderId,
    required String trackingUrl,
  }) async {
    try {
      _showLocalNotification(
        title: '🚚 Order Shipped',
        body: 'Your order #${orderId.substring(0, 8)} is on the way!',
        payload: {
          'type': 'order_shipped',
          'orderId': orderId,
          'userId': userId,
          'trackingUrl': trackingUrl,
        },
      );
      debugPrint('🚚 Order shipped notification sent');
    } catch (e) {
      debugPrint('❌ Error sending shipped notification: $e');
    }
  }

  // Send stock alert to admin
  Future<void> sendStockAlertNotification({
    required String productName,
    required int currentStock,
    required int minStockThreshold,
  }) async {
    try {
      _showLocalNotification(
        title: '⚠️ Low Stock Alert',
        body:
            '$productName stock is low! Current: $currentStock (Threshold: $minStockThreshold)',
        payload: {
          'type': 'stock_alert',
          'productName': productName,
          'stock': currentStock.toString(),
        },
      );
      debugPrint('⚠️ Stock alert notification sent');
    } catch (e) {
      debugPrint('❌ Error sending stock alert: $e');
    }
  }

  // Get FCM token
  Future<String?> getFCMToken() async {
    return await _firebaseMessaging.getToken();
  }

  // Subscribe to topic (for broadcast notifications)
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    debugPrint('✅ Subscribed to topic: $topic');
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    debugPrint('❌ Unsubscribed from topic: $topic');
  }
}
