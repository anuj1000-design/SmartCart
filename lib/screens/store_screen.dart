import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_state_provider.dart';
import '../widgets/product_detail_sheet.dart';
import '../widgets/emoji_display.dart';
import '../widgets/ui_components.dart';
import './advanced_search_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../widgets/staggered_animation.dart';
import '../widgets/shimmer_loading.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  String searchQuery = "";
  String? selectedCategory;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get category from navigation arguments
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('category')) {
      setState(() {
        selectedCategory = args['category'] as String;
      });
    }
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (errorNotification) => setState(() => _isListening = false),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              searchQuery = val.recognizedWords;
              _searchController.text = searchQuery;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }


  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: ScreenFade(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => searchQuery = v),
                        style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                        decoration: InputDecoration(
                          hintText: "Search groceries...",
                          hintStyle: TextStyle(
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                          ),
                          suffixIcon: GestureDetector(
                            onTap: _listen,
                            child: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: _isListening
                                  ? Colors.red
                                  : theme.textTheme.bodyMedium?.color
                                      ?.withValues(alpha: 0.5),
                            ),
                          ),
                          filled: true,
                          fillColor: theme.cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdvancedSearchScreen(),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.tune,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (selectedCategory != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Category: $selectedCategory',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => selectedCategory = null),
                              child: Icon(
                                Icons.close,
                                color: theme.primaryColor,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: appState.products.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: 6,
                          itemBuilder: (context, index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ShimmerLoading.rectangular(
                                    height: double.infinity,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ShimmerLoading.rectangular(height: 16),
                                const SizedBox(height: 4),
                                ShimmerLoading.rectangular(
                                  width: 60,
                                  height: 12,
                                ),
                              ],
                            );
                          },
                        ),
                      )
                    : Builder(
                        builder: (context) {
                          final displayList = appState.products
                              .where(
                                (p) =>
                                    (selectedCategory == null ||
                                        p.category == selectedCategory) &&
                                    (searchQuery.isEmpty ||
                                        p.name.toLowerCase().contains(
                                          searchQuery.toLowerCase(),
                                        ) ||
                                        p.category.toLowerCase().contains(
                                          searchQuery.toLowerCase(),
                                        )),
                              )
                              .toList();

                          if (displayList.isEmpty) {
                            return Center(
                              child: Text(
                                'No products found',
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color?.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: () async {
                              // Refresh products from Firestore
                              await context
                                  .read<AppStateProvider>()
                                  .refreshProducts();
                            },
                            color: theme.primaryColor,
                            backgroundColor: theme.scaffoldBackgroundColor,
                            child: GridView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                0,
                                24,
                                120,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.75,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                              itemCount: displayList.length,
                              itemBuilder: (context, index) {
                                return StaggeredListAnimation(
                                  index: index,
                                  child: _GridProductCard(
                                    product: displayList[index],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridProductCard extends StatefulWidget {
  final Product product;
  const _GridProductCard({required this.product});

  @override
  State<_GridProductCard> createState() => _GridProductCardState();
}

class _GridProductCardState extends State<_GridProductCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
            // Rebuild to show updated favorite status
            if (mounted) setState(() {});
          },
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.15),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    child: Center(
                      child: Hero(
                        tag: "img-${widget.product.id}",
                        child: EmojiDisplay(
                          emoji: widget.product.imageEmoji,
                          fontSize: 48,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.product.category.toString(),
                        style: TextStyle(
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "₹${(widget.product.price / 100).toStringAsFixed(2)}",
                            style: TextStyle(
                              color: theme.textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Check if product is available before adding
                              if (widget.product.stockQuantity <= 0) {
                                HapticFeedback.heavyImpact();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '❌ ${widget.product.name} is out of stock',
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    duration: const Duration(seconds: 1),
                                    backgroundColor: Colors.redAccent,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                return;
                              }

                              appState.addToCart(
                                widget.product,
                                context: context,
                              );
                              HapticFeedback.lightImpact();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: widget.product.stockQuantity <= 0
                                    ? Colors.grey
                                    : theme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                widget.product.stockQuantity <= 0
                                    ? Icons.close
                                    : Icons.add,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
