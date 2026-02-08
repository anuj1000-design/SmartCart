import 'package:flutter/material.dart';
import '../services/loyalty_program_service.dart';

class LoyaltyProgramScreen extends StatefulWidget {
  const LoyaltyProgramScreen({Key? key}) : super(key: key);

  @override
  State<LoyaltyProgramScreen> createState() => _LoyaltyProgramScreenState();
}

class _LoyaltyProgramScreenState extends State<LoyaltyProgramScreen> {
  final LoyaltyProgramService _loyaltyService = LoyaltyProgramService();
  LoyaltySettings? _settings;
  List<LoyaltyTransaction> _transactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final settings = await _loyaltyService.getSettings();
    final transactions = await _loyaltyService.getTransactionHistory();
    
    setState(() {
      _settings = settings;
      _transactions = transactions;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loyalty Program')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Loyalty Program'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Points Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.7),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: StreamBuilder<int>(
                stream: _loyaltyService.getUserPointsStream(),
                builder: (context, snapshot) {
                  final points = snapshot.data ?? 0;
                  final value = _loyaltyService.calculateDiscountForPoints(points);
                  
                  return Column(
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Your Points',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$points',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Worth ₹${(value / 100).toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (points >= (_settings?.minPointsRedeem ?? 100))
                        ElevatedButton(
                          onPressed: () => _showRedeemDialog(points),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          child: const Text(
                            'Redeem Points',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            
            // How it Works
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'How it Works',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.shopping_bag,
                        'Earn ${_settings?.pointsPer100 ?? 10} points for every ₹100 spent',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.redeem,
                        'Redeem points for discounts on your orders',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.card_giftcard,
                        '1 point = ₹${((_settings?.pointsValue ?? 100) / 100).toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.rule,
                        'Minimum ${_settings?.minPointsRedeem ?? 100} points to redeem',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Transaction History
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Transaction History',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_transactions.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No transactions yet'),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = _transactions[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: transaction.isEarned
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.orange.withOpacity(0.1),
                              ),
                              child: Icon(
                                transaction.isEarned ? Icons.add : Icons.remove,
                                color: transaction.isEarned ? Colors.green : Colors.orange,
                              ),
                            ),
                            title: Text(transaction.description),
                            subtitle: Text(
                              transaction.timestamp.toString().substring(0, 16),
                            ),
                            trailing: Text(
                              '${transaction.points > 0 ? '+' : ''}${transaction.points}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: transaction.isEarned ? Colors.green : Colors.orange,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  Future<void> _showRedeemDialog(int currentPoints) async {
    final controller = TextEditingController();
    final settings = _settings!;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Redeem Points'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You have $currentPoints points'),
            Text('Min: ${settings.minPointsRedeem} points'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Points to redeem',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final points = int.tryParse(controller.text);
              if (points == null || points < settings.minPointsRedeem) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Minimum ${settings.minPointsRedeem} points required')),
                );
                return;
              }
              
              if (points > currentPoints) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Insufficient points')),
                );
                return;
              }
              
              try {
                final discount = await _loyaltyService.redeemPoints(points);
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Redeemed $points points for ₹${(discount / 100).toStringAsFixed(2)} discount!',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
                
                _loadData();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }
}
