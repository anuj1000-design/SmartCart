import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../main.dart' show navigatorKey;
import 'payment_success_screen.dart';

class PaymentSelectionScreen extends StatefulWidget {
  final double amount;
  final Function() onPaymentSuccess;

  const PaymentSelectionScreen({
    super.key,
    required this.amount,
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentSelectionScreen> createState() => _PaymentSelectionScreenState();
}

class _PaymentSelectionScreenState extends State<PaymentSelectionScreen> {
  bool isLoading = false;
  String selectedPaymentMethod = 'upi'; // 'upi', 'cod', or 'counter'
  late BuildContext _screenContext;

  Future<void> _initiateUPIPayment() async {
    setState(() => isLoading = true);

    try {
      final appState = Provider.of<AppStateProvider>(context, listen: false);

      // Create payment request in Firestore (pending admin approval)
      final orderDetails = await appState.createPaymentRequest(
        paymentMethod: 'UPI',
        amount: widget.amount,
        onApproved: () {
          // Payment was approved - navigate to success screen
          debugPrint('🎯 UPI onApproved: Navigating to success screen');
        },
        onRejected: (reason) {
          // Payment was rejected - use global navigator key
          debugPrint('🎯 UPI onRejected: Using global navigator key');
          navigatorKey.currentState?.popUntil((route) => route.isFirst);
          if (_screenContext.mounted) {
            ScaffoldMessenger.of(_screenContext).showSnackBar(
              SnackBar(
                content: Text('❌ Payment rejected: $reason'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
      );

      if (orderDetails != null) {
        // Navigate to success screen with order details
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(
                orderNumber: orderDetails['orderNumber'],
                exitCode: orderDetails['exitCode'],
                receiptNo: orderDetails['receiptNo'],
                total: (orderDetails['total'] is int)
                    ? (orderDetails['total'] as int).toDouble()
                    : orderDetails['total'],
                paymentMethod: orderDetails['paymentMethod'],
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment request failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _initiatePayment() async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);

    // Validate stock before attempting payment
    if (!appState.canPlaceOrder()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${appState.getStockErrorMessage()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    if (selectedPaymentMethod == 'upi') {
      await _initiateUPIPayment();
    } else if (selectedPaymentMethod == 'cod') {
      await _initiateCODPayment();
    } else if (selectedPaymentMethod == 'counter') {
      await _initiateCounterPayment();
    }
  }

  Future<void> _initiateCODPayment() async {
    setState(() => isLoading = true);

    try {
      final appState = Provider.of<AppStateProvider>(context, listen: false);

      // Create payment request in Firestore (pending admin approval)
      final orderDetails = await appState.createPaymentRequest(
        paymentMethod: 'COD',
        amount: widget.amount,
        onApproved: () {
          // Payment was approved - navigate to success screen
          debugPrint('🎯 COD onApproved: Navigating to success screen');
        },
        onRejected: (reason) {
          // Payment was rejected - use global navigator key
          debugPrint('🎯 COD onRejected: Using global navigator key');
          navigatorKey.currentState?.popUntil((route) => route.isFirst);
          if (_screenContext.mounted) {
            ScaffoldMessenger.of(_screenContext).showSnackBar(
              SnackBar(
                content: Text('❌ Payment rejected: $reason'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
      );

      if (orderDetails != null) {
        // Navigate to success screen with order details
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(
                orderNumber: orderDetails['orderNumber'],
                exitCode: orderDetails['exitCode'],
                receiptNo: orderDetails['receiptNo'],
                total: orderDetails['total'],
                paymentMethod: orderDetails['paymentMethod'],
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Request failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _initiateCounterPayment() async {
    setState(() => isLoading = true);

    try {
      final appState = Provider.of<AppStateProvider>(context, listen: false);

      // Create payment request in Firestore (pending admin approval)
      final orderDetails = await appState.createPaymentRequest(
        paymentMethod: 'CASH_COUNTER',
        amount: widget.amount,
        onApproved: () {
          // Payment was approved - navigate to success screen
          debugPrint('🎯 Counter onApproved: Navigating to success screen');
        },
        onRejected: (reason) {
          // Payment was rejected - use global navigator key
          debugPrint('🎯 Counter onRejected: Using global navigator key');
          navigatorKey.currentState?.popUntil((route) => route.isFirst);
          if (_screenContext.mounted) {
            ScaffoldMessenger.of(_screenContext).showSnackBar(
              SnackBar(
                content: Text('❌ Payment rejected: $reason'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
      );

      if (orderDetails != null) {
        // Navigate to success screen with order details
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => PaymentSuccessScreen(
                orderNumber: orderDetails['orderNumber'],
                exitCode: orderDetails['exitCode'],
                receiptNo: orderDetails['receiptNo'],
                total: orderDetails['total'],
                paymentMethod: orderDetails['paymentMethod'],
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Pending approval dialog removed — admin approval flow discontinued.

  @override
  Widget build(BuildContext context) {
    _screenContext = context;
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Amount Display
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'Amount to Pay',
                  style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${widget.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: theme.dividerColor),

          // Payment Method Selection
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Payment Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withAlpha((0.2 * 255).toInt()),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('💳', style: TextStyle(fontSize: 40)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // UPI Payment Option
                  _buildPaymentOption(
                    context,
                    id: 'upi',
                    title: 'UPI Payment',
                    subtitle: 'Pay instantly using any UPI app',
                    emoji: '📱',
                    isSelected: selectedPaymentMethod == 'upi',
                    onTap: () => setState(() => selectedPaymentMethod = 'upi'),
                  ),
                  const SizedBox(height: 16),

                  // Cash on Delivery Option
                  _buildPaymentOption(
                    context,
                    id: 'cod',
                    title: 'Cash on Delivery',
                    subtitle: 'Pay cash when your order arrives',
                    emoji: '💵',
                    isSelected: selectedPaymentMethod == 'cod',
                    onTap: () => setState(() => selectedPaymentMethod = 'cod'),
                  ),
                  const SizedBox(height: 16),

                  // Pay at Counter Option
                  _buildPaymentOption(
                    context,
                    id: 'counter',
                    title: 'Pay at Counter',
                    subtitle: 'Pay cash when you checkout',
                    emoji: '🏪',
                    isSelected: selectedPaymentMethod == 'counter',
                    onTap: () => setState(() => selectedPaymentMethod = 'counter'),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _initiatePayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              selectedPaymentMethod == 'upi'
                                  ? 'Pay with UPI'
                                  : selectedPaymentMethod == 'cod'
                                  ? 'Place Order (COD)'
                                  : 'Place Order',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Info Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: theme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your payment details are secure. SmartCart never stores your information.',
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required String id,
    required String title,
    required String subtitle,
    required String emoji,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final activeColor = theme.primaryColor;
    final inactiveBorderColor = theme.dividerColor;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? activeColor : inactiveBorderColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
        color: isSelected ? activeColor.withValues(alpha: 0.05) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? activeColor.withValues(alpha: 0.2)
                      : theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected ? null : Border.all(color: theme.dividerColor),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? activeColor : inactiveBorderColor,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                    color: isSelected ? activeColor : null,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
