import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/app_state_provider.dart';
import '../widgets/ui_components.dart';

class InventoryManagementScreen extends StatefulWidget {
  const InventoryManagementScreen({super.key});

  @override
  State<InventoryManagementScreen> createState() =>
      _InventoryManagementScreenState();
}

class _InventoryManagementScreenState extends State<InventoryManagementScreen> {
  Map<String, dynamic> inventoryStats = {};
  bool isRecalculating = false;
  bool isMonitoring = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final stats = await appState.getInventoryStats();
    setState(() => inventoryStats = stats);
  }

  Future<void> _recalculateInventory() async {
    setState(() => isRecalculating = true);
    try {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      final results = await appState.recalculateInventory();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Fixed ${results['fixed']} discrepancies out of ${results['scanned']} products',
            ),
            backgroundColor: AppTheme.statusSuccess,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      await _loadStats();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: AppTheme.statusError,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isRecalculating = false);
    }
  }

  Future<void> _monitorInventory() async {
    setState(() => isMonitoring = true);
    try {
      final appState = Provider.of<AppStateProvider>(context, listen: false);
      await appState.monitorInventory();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Inventory monitoring complete!'),
            backgroundColor: AppTheme.statusSuccess,
          ),
        );
      }
      await _loadStats();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: AppTheme.statusError,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isMonitoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('📦 Inventory Management'),
        backgroundColor: AppTheme.darkBg,
        elevation: 0,
      ),
      body: ScreenFade(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Cards
              _buildStatsSection(),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isRecalculating ? null : _recalculateInventory,
                      icon: isRecalculating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  AppTheme.textPrimary,
                                ),
                              ),
                            )
                          : const Icon(Icons.sync),
                      label: const Text('Recalculate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.statusWarning,
                        foregroundColor: AppTheme.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isMonitoring ? null : _monitorInventory,
                      icon: isMonitoring
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  AppTheme.textPrimary,
                                ),
                              ),
                            )
                          : const Icon(Icons.monitor),
                      label: const Text('Monitor'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.textPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Low Stock Alerts
              const Text(
                '🚨 Low Stock Alerts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildAlertsSection(appState),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    if (inventoryStats.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '📊 Total Products',
                '${inventoryStats['totalProducts']}',
                AppTheme.statusInfo,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '📦 Total Items',
                '${inventoryStats['totalItems']}',
                AppTheme.statusSuccess,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '🟡 Low Stock',
                '${inventoryStats['lowStockCount']}',
                AppTheme.statusWarning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '🔴 Out of Stock',
                '${inventoryStats['outOfStockCount']}',
                AppTheme.statusError,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '❌ Critical',
                '${inventoryStats['criticalCount']}',
                AppTheme.accentOrange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                '✅ Health',
                '${inventoryStats['healthPercentage']}%',
                AppTheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textTertiary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection(AppStateProvider appState) {
    return StreamBuilder<QuerySnapshot>(
      stream: appState.getLowStockAlerts(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final alerts = snapshot.data!.docs;

        if (alerts.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.statusSuccess.withValues(alpha: 0.1),
              border: Border.all(color: AppTheme.statusSuccess),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.statusSuccess,
                  size: 48,
                ),
                const SizedBox(height: 12),
                const Text(
                  '✅ All items in good stock!',
                  style: TextStyle(
                    color: AppTheme.statusSuccess,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: alerts.length,
          itemBuilder: (context, index) {
            final alert = alerts[index].data() as Map<String, dynamic>;
            final alertId = alert['id'] ?? '';
            final severity = alert['severity'] ?? 'WARNING';
            final isCritical = severity == 'CRITICAL';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCritical
                    ? AppTheme.statusError.withValues(alpha: 0.1)
                    : AppTheme.statusWarning.withValues(alpha: 0.1),
                border: Border(
                  left: BorderSide(
                    color: isCritical
                        ? AppTheme.statusError
                        : AppTheme.statusWarning,
                    width: 4,
                  ),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alert['productName'] ?? 'Unknown',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${alert['status']} - Only ${alert['currentStock']} units left',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => appState.resolveStockAlert(
                          alertId,
                          note: 'Resolved by admin',
                        ),
                        icon: const Icon(Icons.check),
                        label: const Text('Resolve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCritical
                              ? AppTheme.statusError
                              : AppTheme.statusWarning,
                          foregroundColor: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
