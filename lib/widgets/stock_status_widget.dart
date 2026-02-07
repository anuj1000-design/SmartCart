import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';

/// Widget to display stock status with color coding
class StockStatusIndicator extends StatelessWidget {
  final int stockQuantity;
  final bool showDetails;
  final double? width;

  const StockStatusIndicator({
    super.key,
    required this.stockQuantity,
    this.showDetails = true,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final status = appState.getStockStatus(stockQuantity);

    final statusText = status['status'] as String;
    final isLowStock = (status['isLowStock'] as bool?) ?? false;
    final isCritical = (status['isCritical'] as bool?) ?? false;
    final isEmpty = (status['isEmpty'] as bool?) ?? false;

    late Color bgColor;
    late Color borderColor;
    late Color textColor;

    if (isEmpty) {
      bgColor = Colors.red.shade50;
      borderColor = Colors.red;
      textColor = Colors.red;
    } else if (isCritical) {
      bgColor = Colors.deepOrange.shade50;
      borderColor = Colors.deepOrange;
      textColor = Colors.deepOrange;
    } else if (isLowStock) {
      bgColor = Colors.amber.shade50;
      borderColor = Colors.amber;
      textColor = Colors.amber;
    } else {
      bgColor = Colors.green.shade50;
      borderColor = Colors.green;
      textColor = Colors.green;
    }

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: showDetails
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stock: $stockQuantity units',
                  style: TextStyle(
                    fontSize: 11,
                    color: textColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            )
          : Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
    );
  }
}

/// Widget to show stock badge (compact version)
class StockBadge extends StatelessWidget {
  final int stockQuantity;

  const StockBadge({super.key, required this.stockQuantity});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final status = appState.getStockStatus(stockQuantity);
    final statusEmoji = (status['status'] as String).split(' ')[0];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$statusEmoji $stockQuantity',
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// Widget to show low stock warning banner
class LowStockWarning extends StatelessWidget {
  final String productName;
  final int stockQuantity;
  final int requiredQuantity;

  const LowStockWarning({
    super.key,
    required this.productName,
    required this.stockQuantity,
    required this.requiredQuantity,
  });

  @override
  Widget build(BuildContext context) {
    if (stockQuantity >= requiredQuantity) {
      return const SizedBox.shrink();
    }

    final shortage = requiredQuantity - stockQuantity;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.red.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '⚠️ $productName: Only $stockQuantity available, need $requiredQuantity ($shortage short)',
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget to show inventory health chart
class InventoryHealthCard extends StatelessWidget {
  final Map<String, dynamic> stats;

  const InventoryHealthCard({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return const CircularProgressIndicator();
    }

    final health = double.tryParse(stats['healthPercentage'] ?? '0') ?? 0;
    final outOfStock = stats['outOfStockCount'] ?? 0;
    final critical = stats['criticalCount'] ?? 0;
    final lowStock = stats['lowStockCount'] ?? 0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📊 Inventory Health',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$health%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: health > 75
                        ? Colors.green
                        : health > 50
                        ? Colors.orange
                        : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: health / 100,
                minHeight: 12,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation(
                  health > 75
                      ? Colors.green
                      : health > 50
                      ? Colors.orange
                      : Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHealthStat('🔴 Out', outOfStock, Colors.red),
                _buildHealthStat('❌ Critical', critical, Colors.deepOrange),
                _buildHealthStat('🟡 Low', lowStock, Colors.amber),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthStat(String label, int count, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
