import 'package:flutter/material.dart';
import '../services/budget_service.dart';
import '../widgets/ui_components.dart';

class BudgetSettingsScreen extends StatefulWidget {
  const BudgetSettingsScreen({super.key});

  @override
  State<BudgetSettingsScreen> createState() => _BudgetSettingsScreenState();
}

class _BudgetSettingsScreenState extends State<BudgetSettingsScreen> {
  final _monthlyController = TextEditingController();
  final _weeklyController = TextEditingController();
  bool _enableNotifications = true;
  double _notificationThreshold = 80;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadBudget();
  }

  Future<void> _loadBudget() async {
    setState(() => _isLoading = true);
    try {
      final budget = await BudgetService.getBudget();
      if (budget != null && mounted) {
        _monthlyController.text = (budget['monthlyLimit'] ?? 0).toString();
        _weeklyController.text = (budget['weeklyLimit'] ?? 0).toString();
        _enableNotifications = budget['enableNotifications'] ?? true;
        _notificationThreshold = budget['notificationThreshold'] ?? 80.0;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading budget: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveBudget() async {
    setState(() => _isSaving = true);
    try {
      final monthlyLimit = double.tryParse(_monthlyController.text) ?? 0;
      final weeklyLimit = double.tryParse(_weeklyController.text) ?? 0;

      await BudgetService.saveBudget(
        monthlyLimit: monthlyLimit,
        weeklyLimit: weeklyLimit,
        enableNotifications: _enableNotifications,
        notificationThreshold: _notificationThreshold,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('\u2713 Budget settings saved'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving budget: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _monthlyController.dispose();
    _weeklyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Budget Settings'),
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: CircularProgressIndicator(color: theme.primaryColor),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Settings'),
        backgroundColor: Colors.transparent,
        actions: [
          if (_isSaving)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            )
          else
            IconButton(icon: const Icon(Icons.check), onPressed: _saveBudget),
        ],
      ),
      body: ScreenFade(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: theme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Set spending limits to track your budget and get notifications',
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color?.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Monthly Budget',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set your total spending limit for each month',
              style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7), fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _monthlyController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 16),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.currency_rupee,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
                hintText: 'Enter monthly limit (e.g., 50000)',
                hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5)),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Weekly Budget',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set your total spending limit for each week',
              style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7), fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _weeklyController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontSize: 16),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.currency_rupee,
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                ),
                hintText: 'Enter weekly limit (e.g., 12000)',
                hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5)),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budget Alerts',
                          style: TextStyle(
                            color: theme.textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Get notified when approaching your limit',
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _enableNotifications,
                    onChanged: (value) {
                      setState(() => _enableNotifications = value);
                    },
                    activeTrackColor: Colors.green,
                  ),
                ],
              ),
            ),
            if (_enableNotifications) ...[
              const SizedBox(height: 24),
              Text(
                'Alert Threshold',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Notify when reaching ${_notificationThreshold.round()}% of budget',
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Slider(
                value: _notificationThreshold,
                min: 50,
                max: 95,
                divisions: 9,
                label: '${_notificationThreshold.round()}%',
                activeColor: theme.primaryColor,
                inactiveColor: theme.dividerColor,
                onChanged: (value) {
                  setState(() => _notificationThreshold = value);
                },
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveBudget,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Budget Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
