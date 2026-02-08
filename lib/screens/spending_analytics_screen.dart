import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/budget_service.dart';
import '../widgets/ui_components.dart';
import '../widgets/staggered_animation.dart';

class SpendingAnalyticsScreen extends StatefulWidget {
  const SpendingAnalyticsScreen({super.key});

  @override
  State<SpendingAnalyticsScreen> createState() =>
      _SpendingAnalyticsScreenState();
}

class _SpendingAnalyticsScreenState extends State<SpendingAnalyticsScreen> {
  String _selectedPeriod = 'This Month';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Spending Analytics'),
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Text(
            'Please sign in to view analytics',
            style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Analytics'),
        backgroundColor: Colors.transparent,
        actions: [
          // Advanced Analytics Button
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/analytics-dashboard');
            },
            tooltip: 'Advanced Analytics',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: theme.primaryColor),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
             return Center(
              child: Text(
                'No orders found',
                style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
              ),
            );
          }

          final now = DateTime.now();
          final filteredReceipts = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final timestamp = data['timestamp'] as Timestamp?;
            if (timestamp == null) return false;

            final date = timestamp.toDate();
            if (_selectedPeriod == 'This Month') {
              return date.month == now.month && date.year == now.year;
            } else {
              return date.year == now.year;
            }
          }).toList();

          double totalSpent = 0;
          final categorySpending = <String, double>{};
          final itemCounts = <String, int>{};

          for (var doc in filteredReceipts) {
            final data = doc.data() as Map<String, dynamic>;
            final items = data['items'] as List<dynamic>? ?? [];

            for (var item in items) {
              final name = item['name'] ?? 'Unknown';
              final total = ((item['total'] ?? 0) / 100).toDouble();

              // For simplicity, using item name as category
              // In a real app, products would have categories
              categorySpending[name] = (categorySpending[name] ?? 0) + total;
              itemCounts[name] =
                  (itemCounts[name] ?? 0) + (item['quantity'] ?? 0) as int;
              totalSpent += total;
            }
          }

          // Get top 5 items
          final topItems = itemCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));
          final top5Items = topItems.take(5).toList();

          return ScreenFade(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Period Selector
                  StaggeredListAnimation(
                    index: 0,
                    child: Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(
                              value: 'This Month',
                              label: Text('This Month'),
                            ),
                            ButtonSegment(
                              value: 'This Year',
                              label: Text('This Year'),
                            ),
                          ],
                          selected: {_selectedPeriod},
                          onSelectionChanged: (Set<String> newSelection) {
                            setState(() {
                              _selectedPeriod = newSelection.first;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  ),

                  const SizedBox(height: 24),

                  // Budget Progress
                  StaggeredListAnimation(
                    index: 1,
                    child: FutureBuilder<Map<String, dynamic>>(
                    future: BudgetService.checkBudgetStatus(),
                    builder: (context, budgetSnapshot) {
                      if (budgetSnapshot.hasData) {
                        final budget = budgetSnapshot.data!;
                        final hasMonthly = budget['hasMonthlyLimit'] ?? false;
                        final hasWeekly = budget['hasWeeklyLimit'] ?? false;

                        if (!hasMonthly && !hasWeekly) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.dividerColor),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: theme.textTheme.bodySmall?.color,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'No budget set',
                                        style: TextStyle(
                                          color: theme.textTheme.bodyLarge?.color,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/budget-settings',
                                          );
                                        },
                                        child: Text(
                                          'Set a budget to track your spending \u2192',
                                          style: TextStyle(
                                            color: theme.colorScheme.secondary,
                                            fontSize: 13,
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

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Budget Progress',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.titleLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (hasMonthly)
                              _buildBudgetCard(
                                'Monthly Budget',
                                budget['monthlySpending'] ?? 0.0,
                                budget['monthlyLimit'] ?? 0.0,
                                budget['monthlyPercentage'] ?? 0.0,
                                budget['monthlyExceeded'] ?? false,
                              ),
                            if (hasMonthly && hasWeekly)
                              const SizedBox(height: 12),
                            if (hasWeekly)
                              _buildBudgetCard(
                                'Weekly Budget',
                                budget['weeklySpending'] ?? 0.0,
                                budget['weeklyLimit'] ?? 0.0,
                                budget['weeklyPercentage'] ?? 0.0,
                                budget['weeklyExceeded'] ?? false,
                              ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  ),

                  const SizedBox(height: 24),

                  // Total Spent Card
                  StaggeredListAnimation(
                    index: 2,
                    child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor.withValues(alpha: 0.3),
                          theme.colorScheme.secondary.withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Total Spent',
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${totalSpent.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${filteredReceipts.length} transactions',
                          style: TextStyle(
                            color: theme.textTheme.bodySmall?.color,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ),

                  const SizedBox(height: 32),

                  // Top Items
                  StaggeredListAnimation(
                    index: 3,
                    child: Text(
                    'Most Purchased Items',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                  ),
                  const SizedBox(height: 16),

                  if (top5Items.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'No purchases yet',
                          style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                        ),
                      ),
                    )
                  else
                    ...top5Items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final maxCount = top5Items.first.value;
                      final percentage = (item.value / maxCount);

                      return StaggeredListAnimation(
                        index: 4 + index,
                        child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
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
                                    '${index + 1}. ${item.key}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withValues(
                                      alpha: 0.2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${item.value}x',
                                    style: TextStyle(
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentage,
                                backgroundColor: theme.dividerColor,
                                color: theme.primaryColor,
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      );
                    }),

                  const SizedBox(height: 32),

                  // Spending Breakdown
                  StaggeredListAnimation(
                    index: 9,
                    child: Text(
                    'Spending Breakdown',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                  ),
                  const SizedBox(height: 16),

                  if (categorySpending.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'No spending data',
                          style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                        ),
                      ),
                    )
                  else
                    StaggeredListAnimation(
                      index: 10,
                      child: Container(
                      height: 300,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 60,
                          sections: _buildPieChartSections(categorySpending),
                        ),
                      ),
                    ),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<String, double> categorySpending,
  ) {
    final theme = Theme.of(context);
    final total = categorySpending.values.fold<double>(
      0,
      (acc, value) => acc + value,
    );
    final colors = [
      theme.primaryColor,
      Colors.blue,
      Colors.orange,
      theme.colorScheme.error,
      Colors.purple,
      Colors.cyan,
      theme.primaryColorDark,
      theme.primaryColorLight,
    ];

    final sortedEntries = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.take(8).toList().asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final percentage = (category.value / total * 100);

      return PieChartSectionData(
        color: colors[index % colors.length],
        value: category.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      );
    }).toList();
  }

  Widget _buildBudgetCard(
    String title,
    double spent,
    double limit,
    double percentage,
    bool exceeded,
  ) {
    final theme = Theme.of(context);
    final color = exceeded
        ? theme.colorScheme.error
        : percentage > 80
        ? Colors.orange
        : Colors.green;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: theme.textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                '\u20b9${spent.toStringAsFixed(0)} / \u20b9${limit.toStringAsFixed(0)}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              backgroundColor: theme.dividerColor,
              color: color,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                exceeded
                    ? 'Budget exceeded!'
                    : percentage > 80
                    ? 'Approaching limit'
                    : '${percentage.toStringAsFixed(0)}% used',
                style: TextStyle(color: color, fontSize: 12),
              ),
              Text(
                '₹${(limit - spent).toStringAsFixed(0)} remaining',
                style: TextStyle(
                  color: theme.textTheme.bodySmall?.color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
