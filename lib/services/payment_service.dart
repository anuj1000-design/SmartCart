import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';

enum PaymentApp { googlePay, phonePe, paytm, amazonPay, upiApp }

class PaymentService {
  /// Generate UPI link for payment
  /// Format: upi://pay?pa=upiId&pn=payeeName&am=amount&cu=currency&tr=transactionRef&tn=description
  static String generateUpiLink({
    required String upiId,
    required String payeeName,
    required double amount,
    required String transactionRef,
    String? description,
  }) {
    final upiUrl = Uri(
      scheme: 'upi',
      host: 'pay',
      queryParameters: {
        'pa': upiId,
        'pn': Uri.encodeComponent(payeeName),
        'am': amount.toStringAsFixed(2),
        'cu': 'INR',
        'tr': transactionRef,
        'tn': Uri.encodeComponent(description ?? 'SmartCart Payment'),
      },
    );
    return upiUrl.toString();
  }

  /// Check if UPI is supported on the device
  /// If UPI is supported, at least one payment app is installed
  static Future<bool> isUpiSupported() async {
    try {
      // Minimal UPI URI for capability detection only (not launched)
      final upiLink = Uri.parse('upi://pay?pa=merchant@upi&pn=SmartCart&am=1&cu=INR');
      return await canLaunchUrl(upiLink);
    } catch (e) {
      return true; // Assume supported if check fails
    }
  }

  /// Get all available payment apps (returns all by default since Android UPI routing handles it)
  static Future<List<PaymentApp>> getAvailablePaymentApps() async {
    try {
      final supported = await isUpiSupported();
      if (supported) {
        // Return all apps - let Android UPI routing handle which app to use
        return PaymentApp.values.toList();
      }
    } catch (e) {
      // If check fails, still return all apps
      return PaymentApp.values.toList();
    }
    return [];
  }

  /// Launch payment app with UPI link
  static Future<void> launchPaymentApp({
    required PaymentApp app,
    required String upiLink,
  }) async {
    try {
      // Always use the generic UPI link - Android system will route it to the appropriate app
      final paymentUrl = Uri.parse(upiLink);

      // Try to launch the UPI link
      // Note: canLaunchUrl() might not reliably detect UPI apps on all Android versions,
      // so we attempt to launch even if detection fails
      try {
        await launchUrl(paymentUrl, mode: LaunchMode.externalApplication);
      } catch (e) {
        // If launch fails, provide helpful error message
        throw 'Failed to open payment app. Make sure you have a UPI app installed (Google Pay, PhonePe, Paytm, etc.).';
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get display name for payment app
  static String getPaymentAppName(PaymentApp app) {
    switch (app) {
      case PaymentApp.googlePay:
        return 'Google Pay';
      case PaymentApp.phonePe:
        return 'PhonePe';
      case PaymentApp.paytm:
        return 'Paytm';
      case PaymentApp.amazonPay:
        return 'Amazon Pay';
      case PaymentApp.upiApp:
        return 'UPI App';
    }
  }

  /// Get icon for payment app
  static String getPaymentAppIcon(PaymentApp app) {
    switch (app) {
      case PaymentApp.googlePay:
        return '🔵';
      case PaymentApp.phonePe:
        return '💜';
      case PaymentApp.paytm:
        return '🟦';
      case PaymentApp.amazonPay:
        return '🟠';
      case PaymentApp.upiApp:
        return '💳';
    }
  }

  /// Process payment for express checkout
  /// This simulates a payment process - in production, integrate with actual payment gateway
  Future<bool> processPayment({
    required int amount,
    required List<CartItem> items,
    required String exitCode,
  }) async {
    try {
      // Simulate payment processing delay
      await Future.delayed(const Duration(seconds: 2));

      // For demo purposes, always return success
      // In production, integrate with payment gateway like Stripe, Razorpay, etc.
      return true;
    } catch (e) {
      return false;
    }
  }
}
