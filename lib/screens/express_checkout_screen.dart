import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as cloud;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../providers/app_state_provider.dart';
import '../services/payment_service.dart';
import '../services/pdf_service.dart';
import '../services/budget_service.dart';
import '../services/unique_id_service.dart';

class ExpressCheckoutScreen extends StatefulWidget {
  const ExpressCheckoutScreen({super.key});

  @override
  State<ExpressCheckoutScreen> createState() => _ExpressCheckoutScreenState();
}

class _ExpressCheckoutScreenState extends State<ExpressCheckoutScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isProcessing = false;
  String? _exitCode;
  Map<String, dynamic>? _receiptData;

  @override
  void initState() {
    super.initState();
    _generateExitCode();
  }

  void _generateExitCode() {
    const uuid = Uuid();
    setState(() {
      _exitCode = uuid.v4().replaceAll('-', '').substring(0, 12).toUpperCase();
    });
  }

  Future<void> _processPayment() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      final cartItems = appState.cart;
      final total = appState.cartTotal;

      if (cartItems.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Cart is empty'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isProcessing = false);
        return;
      }

      // Process payment
      debugPrint('🔄 Processing payment for amount: $total (paise)');
      final success = await _paymentService.processPayment(
        amount: total,
        items: cartItems,
        exitCode: _exitCode!,
      );
      debugPrint('💰 Payment result: success=$success');

      if (success) {
        // Create receipt data (exit code will be generated and validated inside _createReceipt)
        debugPrint('💳 Payment successful, creating receipt and order...');
        final receipt = await _createReceipt(cartItems, total);
        debugPrint('✅ Receipt and order creation complete');

        setState(() {
          _receiptData = receipt;
        });

        // Clear cart
        appState.clearCart();

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Payment successful!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Payment failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Express Checkout Error: $e');
      debugPrint('Stack trace: ${StackTrace.current}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<Map<String, dynamic>> _createReceipt(
    List<CartItem> items,
    int total,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('❌ No authenticated user found');
      throw Exception('User not authenticated');
    }
    debugPrint('👤 User authenticated: ${user.uid}');

    // Use shared UniqueIdService for unique IDs
    final ids = await UniqueIdService.generateUniqueOrderIds();
    final receiptId = ids['receiptId']!;
    final orderNumber = ids['orderNumber']!;
    final exitCode = ids['exitCode']!;

    final receipt = {
      'receiptNo': receiptId, // Unique receipt/transaction ID (Full UUID)
      'id': receiptId,
      'orderNumber': orderNumber, // User-friendly order number
      'exitCode': exitCode, // Exit verification code (use the validated one)
      'userId': user.uid,
      'items': items
          .map(
            (item) => {
              'productId': item.product.id,
              'productName': item.product.name,
              'quantity': item.quantity,
              'price': item.product.price,
              'total': item.product.price * item.quantity,
            },
          )
          .toList(),
      'subtotal': total,
      'tax': (total * 0.08).round(), // 8% tax
      'total': (total * 1.08).round(),
      'paymentMethod': 'Express Checkout',
      'storeLocation': 'SmartCart Store #001',
    };

    // Note: Receipt data is now saved to 'orders' collection instead
    // No separate receipts collection needed

    // Create order in orders collection
    debugPrint('📝 Creating order document in orders collection...');
    final orderRef = await FirebaseFirestore.instance.collection('orders').add({
      'receiptNo': receiptId, // Unique receipt/transaction ID (Full UUID)
      'orderNumber': orderNumber, // User-friendly 12-char random order number
      'exitCode': exitCode, // Exit verification code
      'userId': user.uid,
      'items': items
          .map(
            (item) => {
              'productId': item.product.id,
              'productName': item.product.name,
              'quantity': item.quantity,
              'price': item.product.price,
              'total': item.product.price * item.quantity,
            },
          )
          .toList(),
      'subtotal': total,
      'tax': (total * 0.08).round(),
      'total': (total * 1.08).round(),
      'paymentMethod': 'Express Checkout',
      'createdAt': cloud.FieldValue.serverTimestamp(),
      'storeLocation': 'SmartCart Store #001',
    });

    debugPrint(
      '✅ Order created in DB with ID: ${orderRef.id}, Receipt: $receiptId, Order: $orderNumber, Exit: $exitCode',
    );

    // Update stock quantities for each product
    final batch = FirebaseFirestore.instance.batch();
    for (final item in items) {
      final productRef = FirebaseFirestore.instance
          .collection('products')
          .doc(item.product.id);
      batch.update(productRef, {
        'stockQuantity': cloud.FieldValue.increment(-item.quantity),
        'purchaseCount': cloud.FieldValue.increment(item.quantity),
      });
    }
    await batch.commit();

    debugPrint('📦 Stock updated for ${items.length} products');

    // Check budget status and show notification if needed
    await _checkBudgetNotification((receipt['total'] as int) / 100);

    return receipt;
  }

  Future<void> _checkBudgetNotification(double purchaseAmount) async {
    try {
      final budgetStatus = await BudgetService.checkBudgetStatus();

      if (!(budgetStatus['enableNotifications'] ?? false)) return;

      final threshold = budgetStatus['notificationThreshold'] ?? 80.0;

      // Check monthly budget
      if (budgetStatus['hasMonthlyLimit'] ?? false) {
        final monthlyPercentage = budgetStatus['monthlyPercentage'] ?? 0.0;
        final monthlyExceeded = budgetStatus['monthlyExceeded'] ?? false;

        if (monthlyExceeded && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '\u26a0\ufe0f Monthly budget exceeded!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'View',
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pushNamed(context, '/budget-settings');
                },
              ),
            ),
          );
        } else if (monthlyPercentage >= threshold && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '\ud83d\udcb5 ${monthlyPercentage.round()}% of monthly budget used',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }

      // Check weekly budget
      if (budgetStatus['hasWeeklyLimit'] ?? false) {
        final weeklyExceeded = budgetStatus['weeklyExceeded'] ?? false;

        if (weeklyExceeded && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '\u26a0\ufe0f Weekly budget exceeded!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'View',
                textColor: Colors.white,
                onPressed: () {
                  Navigator.pushNamed(context, '/budget-settings');
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking budget: $e');
    }
  }

  Future<void> _saveAsPdf({bool letUserChoose = false}) async {
    if (_receiptData == null) return;

    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              letUserChoose ? 'Choose save location...' : 'Generating PDF...',
            ),
            duration: Duration(seconds: letUserChoose ? 1 : 2),
          ),
        );
      }

      final items = (_receiptData!['items'] as List<dynamic>? ?? [])
          .map(
            (item) => {
              'name': item['productName'] ?? item['name'] ?? 'Unknown Item',
              'quantity': item['quantity'] ?? 0,
              'price': ((item['price'] ?? 0) / 100).toDouble(),
            },
          )
          .toList();

      final filePath = await PdfService.generateReceipt(
        storeName: 'SmartCart Store',
        storeAddress: _receiptData!['storeLocation'] ?? 'SmartCart Store #001',
        phoneNumber: '7020767759',
        email: 'pawarshreyas425@gmail.com',
        exitCode: _exitCode ?? 'UNKNOWN',
        items: items,
        paymentMethod: 'Express Checkout',
        subtotal: ((_receiptData!['subtotal'] ?? 0) / 100).toDouble(),
        tax: ((_receiptData!['tax'] ?? 0) / 100).toDouble(),
        total: ((_receiptData!['total'] ?? 0) / 100).toDouble(),
        letUserChoose: letUserChoose,
      );

      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ PDF saved to: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              letUserChoose ? '❌ Save cancelled' : '❌ Failed to save PDF',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error saving PDF: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showReceiptDialog() {
    if (_receiptData == null) return;
    
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: theme.cardColor,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: 500,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Payment Receipt',
                  style: TextStyle(
                    color: theme.textTheme.titleLarge?.color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Receipt header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2E2E2E) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: isDark ? null : Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'SmartCart Store',
                              style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _receiptData!['storeLocation'] ??
                                  'SmartCart Store',
                              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Receipt #${((_receiptData!['receiptNo']?.toString() ?? 'UNKNOWN').length >= 8 ? (_receiptData!['receiptNo']?.toString() ?? 'UNKNOWN').substring(0, 8) : (_receiptData!['receiptNo']?.toString() ?? 'UNKNOWN')).toUpperCase()}',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Order #${_receiptData!['orderNumber'] ?? 'UNKNOWN'}',
                              style: TextStyle(
                                color: theme.textTheme.bodySmall?.color,
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Items
                      Text(
                        'Items Purchased:',
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(_receiptData!['items'] as List<dynamic>? ?? []).map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item['quantity'] ?? 0}x ${item['productName'] ?? item['name'] ?? 'Unknown Item'}',
                                  style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                                ),
                              ),
                              Text(
                                '₹${((item['total'] ?? 0) / 100).toStringAsFixed(2)}',
                                style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Divider(color: theme.dividerColor),

                      // Totals
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Subtotal:',
                            style: TextStyle(color: theme.textTheme.bodySmall?.color),
                          ),
                          Text(
                            '₹${((_receiptData!['subtotal'] ?? 0) / 100).toStringAsFixed(2)}',
                            style: TextStyle(color: theme.textTheme.bodySmall?.color),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tax:',
                            style: TextStyle(color: theme.textTheme.bodySmall?.color),
                          ),
                          Text(
                            '₹${((_receiptData!['tax'] ?? 0) / 100).toStringAsFixed(2)}',
                            style: TextStyle(color: theme.textTheme.bodySmall?.color),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: TextStyle(
                              color: theme.textTheme.titleMedium?.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '₹${((_receiptData!['total'] ?? 0) / 100).toStringAsFixed(2)}',
                            style: TextStyle(
                              color: theme.textTheme.titleMedium?.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Exit QR Code
                      Center(
                        child: Text(
                          'Exit Verification Code',
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white, // QR needs white background
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: QrImageView(
                            data:
                                _receiptData!['exitCode'] ??
                                _exitCode ??
                                'ERROR',
                            version: QrVersions.auto,
                            size: 120.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          _receiptData!['exitCode'] ?? _exitCode ?? 'ERROR',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text(
                          'Show this code at the exit gate',
                          style: TextStyle(color: theme.textTheme.bodySmall?.color, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      icon: Icon(
                        Icons.picture_as_pdf,
                        color: theme.colorScheme.primary,
                        size: 18,
                      ),
                      label: Text(
                        'Save PDF',
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: theme.colorScheme.primary),
                      ),
                      onPressed: () => _saveAsPdf(letUserChoose: false),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Close',
                        style: TextStyle(color: theme.textTheme.bodySmall?.color),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        final cartItems = appState.cart;
        final subtotal = appState.cartTotal;
        final tax = (subtotal * 0.08).round();
        final total = subtotal + tax;
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Express Checkout',
            ),
          ),
          body: cartItems.isEmpty && _receiptData == null
              ? Center(
                  child: Text(
                    'Your cart is empty',
                    style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 18),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cart summary
                      if (cartItems.isNotEmpty) ...[
                        Text(
                          'Order Summary',
                          style: TextStyle(
                            color: theme.textTheme.titleLarge?.color,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Cart items
                        Container(
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              final item = cartItems[index];
                              return ListTile(
                                leading: Text(
                                  item.product.imageEmoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                title: Text(
                                  item.product.name,
                                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                                ),
                                subtitle: Text(
                                  '${item.quantity}x @ ₹${(item.product.price / 100).toStringAsFixed(2)}',
                                  style: TextStyle(color: theme.textTheme.bodySmall?.color),
                                ),
                                trailing: Text(
                                  '₹${(item.product.price * item.quantity / 100).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: theme.textTheme.bodyLarge?.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Order totals
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Subtotal:',
                                    style: TextStyle(color: theme.textTheme.bodySmall?.color),
                                  ),
                                  Text(
                                    '₹${(subtotal / 100).toStringAsFixed(2)}',
                                    style: TextStyle(color: theme.textTheme.bodySmall?.color),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tax (8%):',
                                    style: TextStyle(color: theme.textTheme.bodySmall?.color),
                                  ),
                                  Text(
                                    '₹${(tax / 100).toStringAsFixed(2)}',
                                    style: TextStyle(color: theme.textTheme.bodySmall?.color),
                                  ),
                                ],
                              ),
                              Divider(color: theme.dividerColor),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total:',
                                    style: TextStyle(
                                      color: theme.textTheme.titleMedium?.color,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '₹${(total / 100).toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: theme.primaryColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Payment button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isProcessing ? null : _processPayment,
                            child: _isProcessing
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.payment, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        'Pay Now - Express Checkout',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        const Center(
                          child: Text(
                            '⚡ Instant payment • No waiting in line',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      ],

                      // Receipt section (shown after payment)
                      if (_receiptData != null) ...[
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E2E2E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green, width: 2),
                          ),
                          child: Column(
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text(
                                    'Payment Successful!',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Your exit verification code:',
                                style: TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: QrImageView(
                                  data: _exitCode!,
                                  version: QrVersions.auto,
                                  size: 120.0,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _exitCode!,
                                style: const TextStyle(
                                  color: Color(0xFFD0E4FF),
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD0E4FF),
                                  ),
                                  onPressed: _showReceiptDialog,
                                  child: const Text(
                                    'View Full Receipt',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        );
      },
    );
  }
}
