import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../services/pdf_service.dart';
import '../models/models.dart';
import '../widgets/ui_components.dart';
import '../widgets/staggered_animation.dart';

// Parameters for background filtering
class FilterParams {
  final List<QueryDocumentSnapshot> receipts;
  final String searchQuery;
  final DateTimeRange? selectedDateRange;
  final double minAmount;
  final double maxAmount;

  FilterParams({
    required this.receipts,
    required this.searchQuery,
    required this.selectedDateRange,
    required this.minAmount,
    required this.maxAmount,
  });
}

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  DateTimeRange? _selectedDateRange;
  double _minAmount = 0;
  double _maxAmount = 10000;
  bool _showFilters = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reorderItems(Map<String, dynamic> receipt) async {
    final items = receipt['items'] as List<dynamic>? ?? [];
    final appState = Provider.of<AppStateProvider>(context, listen: false);

    int addedCount = 0;
    int skippedCount = 0;
    final List<String> outOfStockItems = [];

    for (final item in items) {
      final int desiredQty = (item['quantity'] ?? 1) as int;
      final String productId = (item['productId'] ?? '').toString();
      final String itemName = (item['productName'] ?? item['name'] ?? 'Unknown Item').toString();

      // Prefer matching by productId; fallback to name if needed
      Product? product = appState.products.firstWhere(
        (p) => p.id == productId && productId.isNotEmpty,
        orElse: () => appState.products.firstWhere(
          (p) => p.name == itemName,
          orElse: () => Product(
            id: productId.isNotEmpty ? productId : itemName,
            name: itemName,
            brand: 'SmartCart',
            description: '',
            category: 'Other',
            price: item['price'] ?? 0,
            barcode: null,
            imageEmoji: '📦',
            color: Colors.green,
            stockQuantity: 0,
          ),
        ),
      );

      // No stock available
      if (product.stockQuantity <= 0) {
        skippedCount += desiredQty;
        outOfStockItems.add(itemName);
        continue;
      }

      // Current quantity already in cart for this product
      final existingCartQty = appState.cart
          .where((c) => c.product.id == product.id)
          .fold<int>(0, (acc, c) => acc + c.quantity);

      final int availableToAdd = (product.stockQuantity - existingCartQty)
          .clamp(0, desiredQty);

      if (availableToAdd <= 0) {
        skippedCount += desiredQty;
        outOfStockItems.add('$itemName (max stock reached)');
        continue;
      }

      for (int i = 0; i < availableToAdd; i++) {
        appState.addToCart(product, context: context);
        addedCount++;
      }

      if (availableToAdd < desiredQty) {
        skippedCount += (desiredQty - availableToAdd);
        outOfStockItems.add('$itemName (only $availableToAdd of $desiredQty available)');
      }
    }

    if (!mounted) return;

    if (addedCount > 0 && skippedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✓ Added $addedCount items to cart'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (addedCount > 0 && skippedCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✓ Added $addedCount items\n⚠️ Skipped $skippedCount items (stock limits)',
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      final summary = outOfStockItems.isEmpty
          ? 'No items available to reorder.'
          : outOfStockItems.take(3).join(', ') + (outOfStockItems.length > 3 ? '...' : '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Cannot reorder: $summary'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _shareReceipt(Map<String, dynamic> receipt) async {
    try {
      final items = receipt['items'] as List<dynamic>? ?? [];
      final total = ((receipt['total'] ?? 0) / 100).toStringAsFixed(2);
      final date = receipt['timestamp'] as String?;
      final orderId = (receipt['id']?.toString() ?? 'UNKNOWN')
          .substring(0, 8)
          .toUpperCase();

      String message = '🧾 SmartCart Receipt\n';
      message += '━━━━━━━━━━━━━━━━━━━━\n';
      message += 'Order #$orderId\n';
      message += 'Order Number: ${receipt['orderNumber'] ?? 'N/A'}\n';
      if (date != null) {
        final DateTime dt = DateTime.parse(date);
        message +=
            'Date: ${dt.day}/${dt.month}/${dt.year} at ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}\n';
      }
      message += '\n📦 Items:\n';
      for (var item in items) {
        final qty = item['quantity'] ?? 0;
        final name = item['name'] ?? 'Unknown';
        final price = ((item['total'] ?? 0) / 100).toStringAsFixed(2);
        message += '  $qty× $name - ₹$price\n';
      }
      message += '\n💰 Total: ₹$total\n';
      message += '━━━━━━━━━━━━━━━━━━━━\n';
      message += 'Exit Code: ${receipt['exitCode'] ?? 'N/A'}\n';

      // Try to share PDF if available
      final pdfPath = await PdfService.generateReceipt(
        storeName: 'SmartCart Store',
        storeAddress: receipt['storeLocation'] ?? 'SmartCart Store',
        phoneNumber: '7020767759',
        email: 'pawarshreyas425@gmail.com',
        exitCode: receipt['exitCode'] ?? 'N/A',
        items: items.cast<Map<String, dynamic>>(),
        paymentMethod: receipt['paymentMethod'] ?? 'Cash',
        subtotal: (receipt['subtotal'] ?? 0) / 100,
        tax: (receipt['tax'] ?? 0) / 100,
        total: (receipt['total'] ?? 0) / 100,
      );

      if (pdfPath != null) {
        // ignore: deprecated_member_use
        Share.shareXFiles(
          [XFile(pdfPath)],
          text: message,
          subject: 'SmartCart Receipt #$orderId',
        );
      } else {
        // ignore: deprecated_member_use
        Share.share(message, subject: 'SmartCart Receipt #$orderId');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing receipt: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showReceiptDialog(Map<String, dynamic> receipt) {
    final exitCode = receipt['exitCode'] ?? 'N/A';
    final theme = Theme.of(context);

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
                  'Order Receipt',
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
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Receipt header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: theme.dividerColor),
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
                              receipt['storeLocation'] ?? 'SmartCart Store',
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Order #${receipt['orderNumber'] ?? (receipt['id']?.toString() ?? 'UNKNOWN')}',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontFamily: 'monospace',
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
                      ...(receipt['items'] as List<dynamic>? ?? []).map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${item['quantity'] ?? 0}x ${item['productName'] ?? item['name'] ?? 'Unknown Item'}',
                                  style: TextStyle(
                                    color: theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ),
                              Text(
                                '₹${(((item['total'] ?? 0) / 100)).toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
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
                            style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                          ),
                          Text(
                            '₹${(((receipt['subtotal'] ?? 0) / 100)).toStringAsFixed(2)}',
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tax:',
                            style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                          ),
                          Text(
                            '₹${(((receipt['tax'] ?? 0) / 100)).toStringAsFixed(2)}',
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
                            ),
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
                              color: theme.textTheme.titleLarge?.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '₹${(((receipt['total'] ?? 0) / 100)).toStringAsFixed(2)}',
                            style: TextStyle(
                              color: theme.textTheme.titleLarge?.color,
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: QrImageView(
                            data: exitCode,
                            version: QrVersions.auto,
                            size: 120.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          exitCode,
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
                          style: TextStyle(
                            color: theme.textTheme.bodySmall?.color,
                            fontSize: 12,
                          ),
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
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Close',
                        style: TextStyle(color: theme.textTheme.bodyMedium?.color),
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
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Order History"),
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Text(
            "Please sign in to view order history",
            style: TextStyle(fontSize: 16, color: theme.textTheme.bodyMedium?.color),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History"),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
            ),
            onPressed: () {
              setState(() => _showFilters = !_showFilters);
            },
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/analytics');
            },
          ),
        ],
      ),
      body: ScreenFade(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: 'Search by item name...',
                  hintStyle: TextStyle(color: theme.hintColor),
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.iconTheme.color,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: theme.iconTheme.color,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),

            // Filter Controls
            if (_showFilters)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.calendar_today, size: 18),
                            label: Text(
                              _selectedDateRange == null
                                  ? 'Date Range'
                                  : '${DateFormat('MM/dd').format(_selectedDateRange!.start)} - ${DateFormat('MM/dd').format(_selectedDateRange!.end)}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            onPressed: () async {
                              final range = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                                initialDateRange: _selectedDateRange,
                              );
                              if (range != null) {
                                setState(() => _selectedDateRange = range);
                              }
                            },
                          ),
                        ),
                        if (_selectedDateRange != null) ...[
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              setState(() => _selectedDateRange = null);
                            },
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Amount Range: ₹${_minAmount.toInt()} - ₹${_maxAmount.toInt()}',
                      style: TextStyle(
                        color: theme.textTheme.bodySmall?.color,
                        fontSize: 12,
                      ),
                    ),
                    RangeSlider(
                      values: RangeValues(_minAmount, _maxAmount),
                      min: 0,
                      max: 10000,
                      divisions: 100,
                      labels: RangeLabels(
                        '₹${_minAmount.toInt()}',
                        '₹${_maxAmount.toInt()}',
                      ),
                      onChanged: (values) {
                        setState(() {
                          _minAmount = values.start;
                          _maxAmount = values.end;
                        });
                      },
                    ),
                  ],
                ),
              ),

            // Orders List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .where('userId', isEqualTo: user.uid)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  debugPrint('🔍 Order History Query - User UID: ${user.uid}');
                  debugPrint(
                    '📊 Orders Query State: ${snapshot.connectionState}',
                  );
                  if (snapshot.hasData) {
                    debugPrint(
                      '📦 Found ${snapshot.data?.docs.length ?? 0} orders',
                    );
                  }
                  if (snapshot.hasError) {
                    debugPrint('❌ Query Error: ${snapshot.error}');
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  var receipts = snapshot.data?.docs ?? [];

                  // Sort client-side by timestamp
                  receipts.sort((a, b) {
                    final aTime =
                        (a.data() as Map<String, dynamic>)['createdAt'];
                    final bTime =
                        (b.data() as Map<String, dynamic>)['createdAt'];
                    if (aTime == null || bTime == null) return 0;
                    if (aTime is Timestamp && bTime is Timestamp) {
                      return bTime.compareTo(aTime);
                    }
                    return 0;
                  });

                  // Apply filters
                  final searchQuery = _searchController.text.toLowerCase();
                  receipts = receipts.where((doc) {
                    final receipt = doc.data() as Map<String, dynamic>;
                    final items = receipt['items'] as List<dynamic>? ?? [];
                    final totalInPaise = (receipt['total'] ?? 0) as int;
                    final totalInRupees = totalInPaise / 100;

                    // Search filter
                    if (searchQuery.isNotEmpty) {
                      final hasMatch = items.any((item) {
                        final itemName = (item['name'] ?? '').toString().toLowerCase();
                        return itemName.contains(searchQuery);
                      });
                      if (!hasMatch) return false;
                    }

                    // Date range filter
                    if (_selectedDateRange != null) {
                      final createdAt = receipt['createdAt'];
                      if (createdAt != null && createdAt is Timestamp) {
                        final date = createdAt.toDate();
                        if (date.isBefore(_selectedDateRange!.start) ||
                            date.isAfter(_selectedDateRange!.end.add(const Duration(days: 1)))) {
                          return false;
                        }
                      }
                    }

                    // Amount filter
                    if (totalInRupees < _minAmount || totalInRupees > _maxAmount) {
                      return false;
                    }

                    return true;
                  }).toList();

                  if (receipts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 80,
                            color: theme.disabledColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No orders yet",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Your order history will appear here",
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: receipts.length,
                        separatorBuilder: (c, i) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final receiptDoc = receipts[index];
                          final receipt = receiptDoc.data() as Map<String, dynamic>;
                      final items = receipt['items'] as List<dynamic>? ?? [];
                      final createdAt = receipt['createdAt'];
                      DateTime date = DateTime.now();

                      if (createdAt != null && createdAt is Timestamp) {
                        date = createdAt.toDate();
                      }

                      // Get order number (use orderNumber field or fallback to doc ID)
                      final orderNumber =
                          receipt['orderNumber']?.toString() ??
                          (receiptDoc.id.length >= 8
                                  ? receiptDoc.id.substring(0, 8)
                                  : receiptDoc.id)
                              .toUpperCase();

                      return StaggeredListAnimation(
                        index: index,
                        child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Order #$orderNumber',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Completed',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}",
                              style: TextStyle(
                                color: theme.textTheme.bodySmall?.color,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Text(
                                      "${item['quantity'] ?? 0}x",
                                      style: TextStyle(
                                        color: theme.textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        item['name'] ??
                                            item['productName'] ??
                                            'Unknown Item',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Text(
                                      "₹${((item['total'] ?? 0) / 100).toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              height: 24,
                              color: theme.dividerColor,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Total",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "₹${((receipt['total'] ?? 0) / 100).toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.refresh, size: 18),
                                    label: const Text('Reorder'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => _reorderItems(receipt),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.share, size: 18),
                                    label: const Text('Share'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () => _shareReceipt(receipt),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.receipt, size: 18),
                                label: const Text('View Details'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: theme.textTheme.bodyMedium?.color,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  side: BorderSide(
                                    color: theme.dividerColor,
                                  ),
                                ),
                                onPressed: () => _showReceiptDialog(receipt),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
