import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'diagnostics_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../providers/app_state_provider.dart';
import '../services/favorites_service.dart';
import '../models/models.dart';
import '../widgets/product_tile.dart';
import '../widgets/ui_components.dart';
import '../widgets/staggered_animation.dart';
import 'store_intelligence_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Scaffold(
          // No AppBar, only custom header
          body: RefreshIndicator(
            onRefresh: () => appState.refreshProducts(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Custom header only
                  const StaggeredListAnimation(
                    index: 0,
                    child: _HomeHeader(),
                  ),
                  const SizedBox(height: 24),

                  // Stats
                  StaggeredListAnimation(
                    index: 1,
                    child: Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          icon: Icons.receipt_long,
                          label: "SPENT",
                          value:
                              "₹${(appState.cartTotal / 100).toStringAsFixed(2)}",
                          color: AppTheme.accentBlue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          icon: Icons.shopping_basket,
                          label: "ITEMS",
                          value: "${appState.cartCount}",
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  ),
                  const SizedBox(height: 32),

                  // Categories
                  StaggeredListAnimation(
                    index: 2,
                    child: Text(
                    "Categories",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color, // Dynamic
                    ),
                  ),
                  ),
                  const SizedBox(height: 16),
                  const StaggeredListAnimation(
                    index: 3,
                    child: _CategorySelector(),
                  ),
                  const SizedBox(height: 24),
                  // Favorites Section
                  const StaggeredListAnimation(
                    index: 4,
                    child: _FavoritesSection(),
                  ),
                  const SizedBox(height: 24),
                  // Featured List
                  StaggeredListAnimation(
                    index: 5,
                    child: Text(
                    "Popular Now",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color, // Dynamic
                    ),
                  ),
                  ),
                  const SizedBox(height: 16),
                  // Show popular or filtered products depending on selected category
                  Builder(
                    builder: (context) {
                      final showFiltered = appState.selectedCategory != 'All';
                      final listToShow = showFiltered
                          ? appState.filteredProducts
                          : appState.popularProducts;

                      if (listToShow.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                CircularProgressIndicator(
                                  color: AppTheme.primary,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "Loading products...",
                                  style: TextStyle(
                                    color: AppTheme.textTertiary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: listToShow.length > 10
                            ? 10
                            : listToShow.length,
                        separatorBuilder: (c, i) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return StaggeredListAnimation(
                            index: 6 + index,
                            child: ProductTile(product: listToShow[index]),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // All product listings moved to the Store tab; list removed from Home
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "MORNING";
    if (hour < 17) return "AFTERNOON";
    return "EVENING";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                  child: Text(
                    appState.userProfile.avatarEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "GOOD ${_getTimeOfDay()}",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color, // Dynamic
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      appState.userProfile.name,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.titleLarge?.color, // Dynamic
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StoreIntelligenceScreen(),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor, // Dynamic
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: const Icon(
                      Icons.insights,
                      color: AppTheme.accentPurple,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Debug diagnostics button (visible only in debug builds)
                if (kDebugMode)
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DiagnosticsScreen(),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor, // Dynamic
                        shape: BoxShape.circle,
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: const Icon(
                        Icons.bug_report,
                        color: AppTheme.accentBlue,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await appState.loadNotifications();
                        if (!context.mounted) return;
                        showDialog(
                          context: context,
                          barrierColor: Colors.black.withValues(alpha: 0.6),
                          builder: (context) {
                            final notifications = appState.notifications;
                            return Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 40,
                              ),
                              child: GlassCard(
                                padding: const EdgeInsets.all(0),
                                borderRadius: 20,
                                child: Container(
                                  width: 340,
                                  constraints: const BoxConstraints(
                                    maxWidth: 400,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          20,
                                          20,
                                          20,
                                          0,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.notifications,
                                              color: AppTheme.primary,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 10),
                                            const Text(
                                              'Notifications',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Divider(
                                        height: 1,
                                        color: AppTheme.darkBorder,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 8,
                                        ),
                                        child: notifications.isEmpty
                                            ? Container(
                                                width: double.infinity,
                                                padding: const EdgeInsets.all(
                                                  18,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.darkCardHover,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Row(
                                                  children: [
                                                    Icon(
                                                      Icons.info_outline,
                                                      color:
                                                          AppTheme.textTertiary,
                                                    ),
                                                    SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        'No notifications',
                                                        style: TextStyle(
                                                          color: AppTheme
                                                              .textTertiary,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : SizedBox(
                                                height: 220,
                                                child: ListView.separated(
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      notifications.length,
                                                  separatorBuilder: (c, i) =>
                                                      const SizedBox(height: 8),
                                                  itemBuilder: (context, i) {
                                                    final n = notifications[i];
                                                    return Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            14,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            n['read'] == false
                                                            ? AppTheme
                                                                  .darkCardHover
                                                                  .withValues(
                                                                    alpha: 0.95,
                                                                  )
                                                            : AppTheme.darkCard,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                        border: Border.all(
                                                          color:
                                                              n['read'] == false
                                                              ? AppTheme.primary
                                                                    .withValues(
                                                                      alpha:
                                                                          0.18,
                                                                    )
                                                              : AppTheme
                                                                    .darkBorder,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Icon(
                                                            n['read'] == false
                                                                ? Icons
                                                                      .markunread
                                                                : Icons.drafts,
                                                            color:
                                                                n['read'] ==
                                                                    false
                                                                ? AppTheme
                                                                      .primary
                                                                : AppTheme
                                                                      .textTertiary,
                                                            size: 22,
                                                          ),
                                                          const SizedBox(
                                                            width: 12,
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  n['title'] ??
                                                                      '',
                                                                  style: TextStyle(
                                                                    color:
                                                                        n['read'] ==
                                                                            false
                                                                        ? AppTheme
                                                                              .textPrimary
                                                                        : AppTheme
                                                                              .textTertiary,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        15,
                                                                  ),
                                                                ),
                                                                if ((n['message'] ??
                                                                        '')
                                                                    .isNotEmpty) ...[
                                                                  const SizedBox(
                                                                    height: 2,
                                                                  ),
                                                                  Text(
                                                                    n['message'] ??
                                                                        '',
                                                                    style: const TextStyle(
                                                                      color: AppTheme
                                                                          .textTertiary,
                                                                      fontSize:
                                                                          13,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ],
                                                            ),
                                                          ),
                                                          if (n['read'] ==
                                                              false)
                                                            const Padding(
                                                              padding:
                                                                  EdgeInsets.only(
                                                                    left: 6,
                                                                    top: 2,
                                                                  ),
                                                              child: Icon(
                                                                Icons.fiber_new,
                                                                color:
                                                                    Colors.red,
                                                                size: 16,
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Divider(
                                        height: 1,
                                        color: AppTheme.darkBorder,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                          16,
                                          8,
                                          16,
                                          16,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: PrimaryButton(
                                                label: 'Mark all as read',
                                                onPressed: () async {
                                                  await appState
                                                      .markAllNotificationsRead();
                                                  if (!context.mounted) return;
                                                  Navigator.of(context).pop();
                                                },
                                                backgroundColor:
                                                    AppTheme.primary,
                                                textColor: AppTheme.textPrimary,
                                                width: double.infinity,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: PrimaryButton(
                                                label: 'Close',
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                backgroundColor:
                                                    AppTheme.darkCardHover,
                                                textColor: AppTheme.textPrimary,
                                                width: double.infinity,
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
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor, // Dynamic
                          shape: BoxShape.circle,
                          border: Border.all(color: Theme.of(context).dividerColor),
                        ),
                        child: Icon(
                          Icons.notifications_none_rounded,
                          color: Theme.of(context).iconTheme.color, // Dynamic
                        ),
                      ),
                    ),
                    if (appState.unreadNotificationCount > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${appState.unreadNotificationCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector();

  @override
  Widget build(BuildContext context) {
    final categories = [
      "All",
      "Produce",
      "Dairy",
      "Bakery",
      "Household",
      "Pantry",
    ];
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (c, i) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = appState.selectedCategory == cat;
              return GestureDetector(
                onTap: () => appState.setSelectedCategory(cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary
                        : Theme.of(context).cardColor, // Dynamic
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primary
                          : Theme.of(context).dividerColor, // Dynamic
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white // Primary is always dark enough to need white text
                          : Theme.of(context).textTheme.bodyMedium?.color, // Dynamic
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _FavoritesSection extends StatelessWidget {
  const _FavoritesSection();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FavoritesService.getFavorites(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final favorites = snapshot.data!.docs;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite, color: AppTheme.statusError, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Your Favorites",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color, // Dynamic
                      ),
                    ),
                  ],
                ),
                Text(
                  "${favorites.length} items",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color, // Dynamic
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: favorites.length,
                separatorBuilder: (c, i) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final favData =
                      favorites[index].data() as Map<String, dynamic>;
                  return _FavoriteCard(favoriteData: favData);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Map<String, dynamic> favoriteData;

  const _FavoriteCard({required this.favoriteData});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, child) {
        return GestureDetector(
          onTap: () {
            // Quick add to cart - find product from app state
            try {
              // Find the actual product from app state by name
              final actualProduct = appState.products.firstWhere(
                (p) => p.name == favoriteData['name'],
                orElse: () => Product(
                  id:
                      favoriteData['barcode'] ??
                      favoriteData['name'] ??
                      'unknown',
                  name: favoriteData['name'] ?? 'Unknown',
                  brand: 'SmartCart',
                  description: '',
                  category: favoriteData['category'] ?? 'Other',
                  price: favoriteData['price'] ?? 0,
                  barcode: favoriteData['barcode'],
                  imageEmoji: favoriteData['imageEmoji'] ?? '\ud83d\udce6',
                  color: Color(
                    favoriteData['color'] ?? AppTheme.statusSuccess.toARGB32(),
                  ),
                  stockQuantity: favoriteData['stockQuantity'] ?? 0,
                ),
              );
              appState.addToCart(actualProduct, context: context);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error adding to cart: $e'),
                  backgroundColor: AppTheme.statusError,
                ),
              );
            }
          },
          child: Container(
            width: 90,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor, // Dynamic
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).dividerColor), // Dynamic
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  favoriteData['imageEmoji'] ?? '\ud83d\udce6',
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 4),
                Text(
                  favoriteData['name'] ?? 'Unknown',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color, // Dynamic
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
