import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/analytics_service.dart';
import '../widgets/ui_components.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  late Future<Map<String, dynamic>> _statsFuture;
  late Future<List<Map<String, dynamic>>> _popularFuture;
  late Future<List<Map<String, dynamic>>> _trendingFuture;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    _statsFuture = AnalyticsService().getTotalStats();
    _popularFuture = AnalyticsService().getPopularProducts();
    _trendingFuture = AnalyticsService().getTrendingSearches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Analytics Dashboard'),
        backgroundColor: AppTheme.darkBg,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(_refreshData);
            },
          ),
        ],
      ),
      body: ScreenFade(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(_refreshData);
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<Map<String, dynamic>>(
                  future: _statsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primary,
                        ),
                      );
                    }

                    final stats = snapshot.data ?? {};
                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        _buildStatCard(
                          title: 'Total Views',
                          value: '${stats['totalViews'] ?? 0}',
                          color: AppTheme.accentBlue,
                          icon: Icons.visibility,
                        ),
                        _buildStatCard(
                          title: 'Cart Adds',
                          value: '${stats['totalCarts'] ?? 0}',
                          color: AppTheme.statusWarning,
                          icon: Icons.shopping_cart,
                        ),
                        _buildStatCard(
                          title: 'Purchases',
                          value: '${stats['totalPurchases'] ?? 0}',
                          color: AppTheme.statusSuccess,
                          icon: Icons.check_circle,
                        ),
                        _buildStatCard(
                          title: 'Searches',
                          value: '${stats['totalSearches'] ?? 0}',
                          color: AppTheme.accentPurple,
                          icon: Icons.search,
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  '🏆 Top Products',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _popularFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primary,
                        ),
                      );
                    }

                    final products = snapshot.data ?? [];
                    if (products.isEmpty) {
                      return const Center(
                        child: Text(
                          'No data yet',
                          style: TextStyle(color: AppTheme.textTertiary),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.accentBlue.withValues(
                                alpha: 0.2,
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            title: Text(
                              product['name'] ?? 'Unknown',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              '👁️ ${product['views']} views | 🛒 ${product['carts']} carts | 💰 ₹${((product['revenue'] ?? 0) / 100).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textTertiary,
                              ),
                            ),
                            trailing: Chip(
                              label: Text(
                                '${product['purchases'] ?? 0} sold',
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              backgroundColor: AppTheme.statusSuccess
                                  .withValues(alpha: 0.2),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  '🔍 Trending Searches',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _trendingFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primary,
                        ),
                      );
                    }

                    final searches = snapshot.data ?? [];
                    if (searches.isEmpty) {
                      return const Center(
                        child: Text(
                          'No searches yet',
                          style: TextStyle(color: AppTheme.textTertiary),
                        ),
                      );
                    }

                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: searches.take(10).map((search) {
                        return Chip(
                          label: Text(
                            '${search['query']} (${search['count']})',
                            style: const TextStyle(color: AppTheme.textPrimary),
                          ),
                          backgroundColor: AppTheme.accentPurple.withValues(
                            alpha: 0.2,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.textPrimary, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
