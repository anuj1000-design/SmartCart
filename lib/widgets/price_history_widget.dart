import 'package:flutter/material.dart';
import '../services/price_history_service.dart';

class PriceHistoryWidget extends StatelessWidget {
  final String productId;

  const PriceHistoryWidget({Key? key, required this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PriceHistoryEntry>>(
      future: PriceHistoryService().getPriceHistory(productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final history = snapshot.data ?? [];

        if (history.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.trending_up, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    'No price history available',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          );
        }

        return FutureBuilder<PriceSummary>(
          future: PriceHistoryService().getPriceSummary(productId),
          builder: (context, summarySnapshot) {
            final summary = summarySnapshot.data;

            return Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.show_chart, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          'Price History',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Price Summary Cards
                    if (summary != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildPriceStat(
                              'Current',
                              summary.currentPrice,
                              Colors.blue,
                              context,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildPriceStat(
                              'Lowest',
                              summary.lowestPrice,
                              Colors.green,
                              context,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildPriceStat(
                              'Highest',
                              summary.highestPrice,
                              Colors.red,
                              context,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildPriceStat(
                              'Average',
                              summary.averagePrice,
                              Colors.orange,
                              context,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Deal indicator
                      if (summary.isGoodDeal)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.local_offer, color: Colors.green.shade700, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Great Deal! ${summary.savingsPercent}% off from highest price',
                                  style: TextStyle(
                                    color: Colors.green.shade900,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],

                    // Simple line chart visualization
                    SizedBox(
                      height: 150,
                      child: _buildSimpleLineChart(history, context),
                    ),
                    const SizedBox(height: 16),

                    // Price history list
                    Text(
                      'Recent Changes',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: history.length > 5 ? 5 : history.length,
                      separatorBuilder: (_, __) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final entry = history[index];
                        return Row(
                          children: [
                            Icon(
                              entry.isPriceIncrease
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              color: entry.isPriceIncrease
                                  ? Colors.red
                                  : Colors.green,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '₹${(entry.oldPrice / 100).toStringAsFixed(2)} → ₹${(entry.newPrice / 100).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    entry.timestamp.toString().substring(0, 16),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: entry.isPriceIncrease
                                    ? Colors.red.shade50
                                    : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${entry.changePercent > 0 ? '+' : ''}${entry.changePercent}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: entry.isPriceIncrease
                                      ? Colors.red.shade700
                                      : Colors.green.shade700,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPriceStat(String label, int price, Color color, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '₹${(price / 100).toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleLineChart(List<PriceHistoryEntry> history, BuildContext context) {
    // Reverse to show oldest to newest
    final reversedHistory = history.reversed.toList();
    final prices = reversedHistory.map((e) => e.newPrice).toList();
    
    if (prices.isEmpty) return const SizedBox();

    final minPrice = prices.reduce((a, b) => a < b ? a : b).toDouble();
    final maxPrice = prices.reduce((a, b) => a > b ? a : b).toDouble();
    final priceRange = maxPrice - minPrice;

    return CustomPaint(
      painter: _SimpleLineChartPainter(
        prices: prices,
        minPrice: minPrice,
        maxPrice: maxPrice,
        priceRange: priceRange,
      ),
      child: Container(),
    );
  }
}

class _SimpleLineChartPainter extends CustomPainter {
  final List<int> prices;
  final double minPrice;
  final double maxPrice;
  final double priceRange;

  _SimpleLineChartPainter({
    required this.prices,
    required this.minPrice,
    required this.maxPrice,
    required this.priceRange,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    // Draw grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Create path
    final path = Path();
    final fillPath = Path();
    
    for (int i = 0; i < prices.length; i++) {
      final x = size.width * (i / (prices.length - 1));
      final normalizedPrice = priceRange > 0 
          ? (prices[i] - minPrice) / priceRange
          : 0.5;
      final y = size.height - (size.height * normalizedPrice);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Complete fill path
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw fill and line
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Draw dots
    for (int i = 0; i < prices.length; i++) {
      final x = size.width * (i / (prices.length - 1));
      final normalizedPrice = priceRange > 0 
          ? (prices[i] - minPrice) / priceRange
          : 0.5;
      final y = size.height - (size.height * normalizedPrice);
      
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()..color = Colors.blue,
      );
      canvas.drawCircle(
        Offset(x, y),
        2,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
