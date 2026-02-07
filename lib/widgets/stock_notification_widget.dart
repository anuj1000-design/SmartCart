import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

/// Shows total stock status and availability in cart
class CartStockStatus extends StatelessWidget {
  const CartStockStatus({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);

    // Calculate total stock for items in cart
    int totalStockAvailable = 0;
    int totalItemsInCart = 0;
    bool hasIssue = false;

    for (var item in appState.cart) {
      totalItemsInCart += item.quantity;
      totalStockAvailable += item.product.stockQuantity;

      if (item.quantity > item.product.stockQuantity) {
        hasIssue = true;
      }
    }

    final stockStatus = appState.getStockStatus(totalStockAvailable);
    final isEmpty = (stockStatus['isEmpty'] as bool?) ?? false;
    final isCritical = (stockStatus['isCritical'] as bool?) ?? false;

    late Color indicatorColor;
    late IconData indicatorIcon;

    if (hasIssue || isEmpty) {
      indicatorColor = Colors.red;
      indicatorIcon = Icons.error;
    } else if (isCritical) {
      indicatorColor = Colors.deepOrange;
      indicatorIcon = Icons.warning;
    } else {
      indicatorColor = Colors.green;
      indicatorIcon = Icons.check_circle;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: indicatorColor.withValues(alpha: 0.1),
        border: Border.all(color: indicatorColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(indicatorIcon, color: indicatorColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Stock Availability',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 4),
                if (hasIssue)
                  Text(
                    '❌ Insufficient stock for some items!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  )
                else if (isEmpty)
                  Text(
                    '❌ Out of stock - Cannot checkout',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  )
                else if (isCritical)
                  Text(
                    '⚠️ Low stock - Limited availability',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  )
                else
                  Text(
                    '✅ All items in stock',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total: $totalStockAvailable',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Items: $totalItemsInCart',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shows stock for individual cart items with warnings
class CartItemStockInfo extends StatelessWidget {
  final int itemQuantity;
  final int availableStock;
  final String productName;

  const CartItemStockInfo({
    super.key,
    required this.itemQuantity,
    required this.availableStock,
    required this.productName,
  });

  @override
  Widget build(BuildContext context) {
    final isInsufficient = itemQuantity > availableStock;
    final shortage = isInsufficient ? itemQuantity - availableStock : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isInsufficient
            ? Colors.red.shade900.withValues(alpha: 0.3)
            : Colors.green.shade900.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isInsufficient ? Icons.warning : Icons.check_circle,
            size: 14,
            color: isInsufficient ? Colors.red : Colors.green,
          ),
          const SizedBox(width: 4),
          Text(
            isInsufficient
                ? '$availableStock avail (-$shortage)'
                : '$availableStock avail',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isInsufficient ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

/// Notification popup for stock issues
class StockIssueNotification {
  static void showInsufficientStock(
    BuildContext context,
    String productName,
    int needed,
    int available,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '❌ Insufficient Stock',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$productName: Only $available available, need $needed',
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void showOutOfStock(BuildContext context, String productName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.block, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '🔴 $productName - Out of Stock',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade900,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void showLowStock(
    BuildContext context,
    String productName,
    int stock,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '⚠️ $productName - Only $stock left',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static Future<void> showStockConfirmationDialog(
    BuildContext context,
    String productName,
    int available,
    int requested,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2022),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '📦 Stock Issue',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product: $productName',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade900.withValues(alpha: 0.3),
                  border: Border.all(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '❌ Only $available units available',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You requested: $requested units',
                      style: TextStyle(
                        color: Colors.red.shade200,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Shortage: ${requested - available} units',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Would you like to:',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel Order',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Adjust Quantity',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: Text(
                'Order $available units',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
