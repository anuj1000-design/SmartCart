import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/app_state_provider.dart';
import '../widgets/emoji_display.dart';
import '../widgets/stock_notification_widget.dart';
import '../widgets/ui_components.dart';
import '../widgets/staggered_animation.dart';
import 'payment_selection_screen.dart';
import 'express_checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Cart",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.statusError),
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: AppTheme.darkCard,
                    title: const Text(
                      'Clear Cart',
                      style: TextStyle(color: AppTheme.textPrimary),
                    ),
                    content: const Text(
                      'Are you sure you want to remove all items from your cart?',
                      style: TextStyle(color: AppTheme.textTertiary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.statusError,
                        ),
                        child: const Text('Clear Cart'),
                      ),
                    ],
                  );
                },
              );

              if (confirmed == true) {
                appState.clearCart();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cart cleared'),
                      backgroundColor: AppTheme.statusError,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: ScreenFade(
        child: appState.cart.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 80,
                      color: Theme.of(context).disabledColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Your cart is empty",
                      style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: appState.cart.length,
                      separatorBuilder: (c, i) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final item = appState.cart[index];
                        return StaggeredListAnimation(
                          index: index,
                          child: _CartTile(item: item),
                        );
                      },
                    ),
                  ),
                  const CartStockStatus(),
                  _buildCheckoutArea(context),
                ],
              ),
      ),
    );
  }

  Widget _buildCheckoutArea(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Subtotal",
                  style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                ),
                Text(
                  "₹${(appState.cartTotal / 100).toStringAsFixed(2)}",
                  style: TextStyle(
                    color: theme.textTheme.titleMedium?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: theme.dividerColor),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total",
                  style: TextStyle(
                    color: theme.textTheme.titleLarge?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  "₹${(appState.cartTotal / 100).toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "In-store & Home Delivery Available",
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            // Express Checkout Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExpressCheckoutScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "⚡ Express Checkout",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "No Lines",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Traditional Checkout Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to payment selection screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentSelectionScreen(
                        // appState.cartTotal is stored in paise; convert to INR for display and payment flows
                        amount: appState.cartTotal.toDouble() / 100.0,
                        onPaymentSuccess: () {
                          // Show success dialog
                          showDialog(
                            context: context,
                            builder: (c) => const _SuccessDialog(),
                          );
                        },
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: AppTheme.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  "Traditional Checkout",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 32), // Add extra space below button
          ],
        ),
      ),
    );
  }
}

class _CartTile extends StatelessWidget {
  final CartItem item;
  const _CartTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: item.product.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: EmojiDisplay(emoji: item.product.imageEmoji, fontSize: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  "₹${(item.product.price / 100).toStringAsFixed(2)}",
                  style: const TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                CartItemStockInfo(
                  itemQuantity: item.quantity,
                  availableStock: item.product.stockQuantity,
                  productName: item.product.name,
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.darkCardHover,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.remove,
                    size: 16,
                    color: AppTheme.textPrimary,
                  ),
                  onPressed: () => appState.removeFromCart(item.product),
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                Text(
                  "${item.quantity}",
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add,
                    size: 16,
                    color: AppTheme.textPrimary,
                  ),
                  onPressed: item.quantity < item.product.stockQuantity
                      ? () => appState.addToCart(item.product, context: context)
                      : null,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: AppTheme.statusSuccess,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              "Order Placed!",
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Your groceries are on the way.",
              style: TextStyle(color: AppTheme.textTertiary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Close",
                style: TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
