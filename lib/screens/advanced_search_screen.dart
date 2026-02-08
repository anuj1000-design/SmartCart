import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/app_state_provider.dart';
import '../widgets/product_detail_sheet.dart';
import '../widgets/emoji_display.dart';
import '../widgets/ui_components.dart';

enum SortBy { popularity, priceAsc, priceDesc }

class AdvancedSearchScreen extends StatefulWidget {
  const AdvancedSearchScreen({super.key});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _searchQuery = '';

  // Filter state
  int _minPrice = 0;
  int _maxPrice = 100000; // Max ₹1000 (100000 paise)
  final Set<String> _selectedBrands = {};
  final Set<String> _selectedTags = {};
  SortBy _sortBy = SortBy.popularity;

  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _searchController = TextEditingController(text: _searchQuery);
    // Refresh products when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppStateProvider>(context, listen: false).refreshProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              _searchQuery = result.recognizedWords;
              _searchController.text = _searchQuery;
            });
          },
        );
      }
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speechToText.stop();
      setState(() => _isListening = false);
    }
  }

  List<Product> _getFilteredAndSortedProducts(List<Product> products) {
    final filtered = products.where((p) {
      // Search query filter
      bool matchesSearch =
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.brand.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase());

      // Price filter
      bool matchesPrice = p.price >= _minPrice && p.price <= _maxPrice;

      // Brand filter
      bool matchesBrand =
          _selectedBrands.isEmpty || _selectedBrands.contains(p.brand);

      // Tags filter
      bool matchesTags =
          _selectedTags.isEmpty ||
          _selectedTags.any(
            (tag) => p.tags.contains(tag),
          );

      if (!matchesPrice) {
        debugPrint(
          '🔍 ${p.name}: Price ${p.price} not in range $_minPrice-$_maxPrice',
        );
      }
      if (!matchesTags) {
        debugPrint(
          '🔍 ${p.name}: Tags mismatch - has ${p.tags}, needs $_selectedTags',
        );
      }

      return matchesSearch && matchesPrice && matchesBrand && matchesTags;
    }).toList();

    // Apply sorting
    switch (_sortBy) {
      case SortBy.priceAsc:
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortBy.priceDesc:
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortBy.popularity:
        break;
    }

    return filtered;
  }

  Set<String> _getAllBrands(List<Product> products) {
    return products.map((p) => p.brand).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        debugPrint(
          '🔍 Advanced Search - Total products: ${appState.products.length}',
        );
        final filteredProducts = _getFilteredAndSortedProducts(
          appState.products,
        );
        debugPrint(
          '🔍 Advanced Search - Filtered products: ${filteredProducts.length}',
        );
        final allBrands = _getAllBrands(appState.products);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Advanced Search'),
            elevation: 0,
            backgroundColor: AppTheme.darkBg,
          ),
          body: SafeArea(
            bottom: false,
            child: ScreenFade(
              child: Column(
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) => setState(() => _searchQuery = v),
                            style: const TextStyle(color: AppTheme.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Search products...',
                              hintStyle: TextStyle(
                                color: AppTheme.textPrimary.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppTheme.textPrimary.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              filled: true,
                              fillColor: AppTheme.darkCard.withValues(
                                alpha: 0.4,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _isListening
                              ? _stopListening
                              : _startListening,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _isListening
                                  ? AppTheme.primary
                                  : AppTheme.darkCard.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: AppTheme.textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Filter chips
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          PopupMenuButton<SortBy>(
                            onSelected: (value) =>
                                setState(() => _sortBy = value),
                            child: Chip(
                              label: Text(
                                'Sort: ${_sortBy.name}',
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              backgroundColor: AppTheme.darkCardHover
                                  .withValues(alpha: 0.8),
                            ),
                            itemBuilder: (context) => SortBy.values
                                .map(
                                  (e) => PopupMenuItem(
                                    value: e,
                                    child: Text(e.name),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _showFilterSheet(context, allBrands),
                            child: Chip(
                              label: const Text(
                                'Filters',
                                style: TextStyle(color: AppTheme.textPrimary),
                              ),
                              backgroundColor: AppTheme.darkCardHover
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Products
                  Expanded(
                    child: filteredProducts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: AppTheme.textPrimary.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No products found',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemCount: filteredProducts.length,
                            itemBuilder: (context, index) {
                              return _GridProductCard(
                                product: filteredProducts[index],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFilterSheet(BuildContext context, Set<String> allBrands) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkCard,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Price: ₹${(_minPrice / 100).toStringAsFixed(0)} - ₹${(_maxPrice / 100).toStringAsFixed(0)}',
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
                RangeSlider(
                  values: RangeValues(
                    _minPrice.toDouble(),
                    _maxPrice.toDouble(),
                  ),
                  min: 0,
                  max: 100000,
                  activeColor: AppTheme.primary,
                  inactiveColor: AppTheme.darkBorder,
                  onChanged: (RangeValues values) {
                    setModalState(() {
                      _minPrice = values.start.toInt();
                      _maxPrice = values.end.toInt();
                    });
                    setState(() {});
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      setModalState(() {
                        _minPrice = 0;
                        _maxPrice = 100000;
                        _selectedBrands.clear();
                      });
                      setState(() {});
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkCardHover.withValues(
                        alpha: 0.8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Reset',
                      style: TextStyle(color: AppTheme.textPrimary),
                    ),
                  ),
                ),
              ],
            ),
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
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) => GestureDetector(
        onTap: () async {
          await showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) => ProductDetailSheet(product: widget.product),
          );
          // Rebuild to show updated favorite status
          if (mounted) setState(() {});
        },
        child: Container(
          decoration: BoxDecoration(
            color: widget.product.color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Center(
                      child: EmojiDisplay(
                        emoji: widget.product.imageEmoji,
                        fontSize: 64,
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${(widget.product.price / 100).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => appState.toggleFavorite(widget.product),
                  child: Icon(
                    widget.product.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    size: 20,
                    color: widget.product.isFavorite
                        ? AppTheme.statusError
                        : AppTheme.textTertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
