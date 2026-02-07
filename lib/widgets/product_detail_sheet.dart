import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state_provider.dart';
import '../services/favorites_service.dart';
import 'stock_notification_widget.dart';

class ProductDetailSheet extends StatefulWidget {
  final Product product;
  const ProductDetailSheet({super.key, required this.product});

  @override
  State<ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<ProductDetailSheet> {
  bool _isFavorite = false;
  bool _isLoadingFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await FavoritesService.isFavorite(
      widget.product.barcode ?? widget.product.name,
    );
    if (mounted) {
      setState(() => _isFavorite = isFav);
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => _isLoadingFavorite = true);
    try {
      final productData = {
        'name': widget.product.name,
        'barcode': widget.product.barcode,
        'price': widget.product.price,
        'category': widget.product.category,
        'imageEmoji': widget.product.imageEmoji,
        'color': widget.product.color.toARGB32(),
      };

      final newState = await FavoritesService.toggleFavorite(productData);
      if (mounted) {
        setState(() {
          _isFavorite = newState;
          _isLoadingFavorite = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newState
                  ? '\u2764\ufe0f Added to favorites'
                  : 'Removed from favorites',
            ),
            backgroundColor: newState ? Colors.green : Colors.grey[700],
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingFavorite = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF151719),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.product.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB0C4FF),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: _isLoadingFavorite ? null : _toggleFavorite,
                      icon: _isLoadingFavorite
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Icon(
                              _isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: _isFavorite
                                  ? Colors.redAccent
                                  : Colors.white,
                              size: 30,
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  "Description",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.product.description,
                  style: const TextStyle(color: Colors.grey, height: 1.5),
                ),
                const SizedBox(height: 24),
                // Stock Status
                _StockStatusWidget(product: widget.product, appState: appState),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _InfoBadge(
                      label: "Organic",
                      icon: Icons.eco,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 12),
                    _InfoBadge(
                      label: "4.8 Stars",
                      icon: Icons.star,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom Action
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.white.withAlpha((0.05 * 255).toInt()),
                ),
              ),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Price",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      "₹${(widget.product.price / 100).toStringAsFixed(2)}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: widget.product.stockQuantity > 0
                          ? () {
                              if (widget.product.stockQuantity <= 5) {
                                StockIssueNotification.showLowStock(
                                  context,
                                  widget.product.name,
                                  widget.product.stockQuantity,
                                );
                              }
                              appState.addToCart(
                                widget.product,
                                context: context,
                              );
                              Navigator.pop(context);
                            }
                          : () {
                              StockIssueNotification.showOutOfStock(
                                context,
                                widget.product.name,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.product.stockQuantity > 0
                            ? const Color(0xFFD0E4FF)
                            : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        widget.product.stockQuantity > 0
                            ? "Add to Cart"
                            : "Out of Stock",
                        style: TextStyle(
                          color: widget.product.stockQuantity > 0
                              ? Colors.black
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
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

class _InfoBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _InfoBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha((0.3 * 255).toInt())),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _StockStatusWidget extends StatelessWidget {
  final Product product;
  final AppStateProvider appState;

  const _StockStatusWidget({required this.product, required this.appState});

  @override
  Widget build(BuildContext context) {
    final status = appState.getStockStatus(product.stockQuantity);
    late Color statusColor;
    late IconData statusIcon;
    late String statusText;

    if (product.stockQuantity <= 0) {
      statusColor = Colors.red;
      statusIcon = Icons.block;
      statusText = 'Out of Stock';
    } else if (status['isCritical'] == true) {
      statusColor = Colors.deepOrange;
      statusIcon = Icons.warning;
      statusText = 'Critical Stock: ${product.stockQuantity} left';
    } else if (status['isLowStock'] == true) {
      statusColor = Colors.amber;
      statusIcon = Icons.info;
      statusText = 'Low Stock: ${product.stockQuantity} left';
    } else {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'In Stock: ${product.stockQuantity} available';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        border: Border.all(color: statusColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Availability',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
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
