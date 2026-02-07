import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state_provider.dart';
import '../services/favorites_service.dart';
import 'product_detail_sheet.dart';
import 'emoji_display.dart';

class ProductTile extends StatefulWidget {
  final Product product;
  const ProductTile({super.key, required this.product});

  @override
  State<ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> {
  bool _isFavorite = false;
  bool _isLoading = false;

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
    setState(() => _isLoading = true);
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
          _isLoading = false;
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
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return GestureDetector(
          onTap: () async {
            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (c) => ProductDetailSheet(product: widget.product),
            );
            // Refresh favorite status when sheet is closed
            _checkFavoriteStatus();
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor, // Use theme card color
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Theme.of(context).dividerColor), // Use theme divider
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: widget.product.color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: EmojiDisplay(
                      emoji: widget.product.imageEmoji,
                      fontSize: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color, // Dynamic text
                        ),
                      ),
                      Text(
                        widget.product.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color, // Dynamic text
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Text(
                          "\u20b9${(widget.product.price / 100).toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color, // Dynamic text
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _isLoading ? null : _toggleFavorite,
                          child: Icon(
                            _isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: _isFavorite ? Colors.red : Colors.grey,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () =>
                          appState.addToCart(widget.product, context: context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFD0E4FF,
                          ).withAlpha((0.2 * 255).toInt()),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Color(0xFFD0E4FF),
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
