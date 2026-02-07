import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state_provider.dart';
import '../widgets/ui_components.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  void _addCard() {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    if (_cardNumberController.text.isEmpty ||
        _cardHolderController.text.isEmpty ||
        _expiryController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }
    appState.addPaymentMethod(
      _cardNumberController.text,
      _cardHolderController.text,
      _expiryController.text,
    );
    _cardNumberController.clear();
    _cardHolderController.clear();
    _expiryController.clear();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Card added successfully!")));
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment Methods"),
        backgroundColor: Colors.transparent,
      ),
      body: ScreenFade(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Saved Cards",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (appState.paymentMethods.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      "No payment methods added",
                      style: TextStyle(color: Theme.of(context).iconTheme.color),
                    ),
                  ),
                )
              else
                ...appState.paymentMethods.map(
                  (method) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.credit_card,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "•••• ${method.cardNumber.substring(method.cardNumber.length - 4)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                              Text(
                                method.cardHolder,
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                "Expires: ${method.expiryDate}",
                                style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppTheme.statusError,
                          ),
                          onPressed: () =>
                              appState.removePaymentMethod(method.id),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              const Text(
                "Add New Card",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: "Card Number",
                  hintText: "1234 5678 9012 3456",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
                maxLength: 16,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cardHolderController,
                decoration: InputDecoration(
                  labelText: "Card Holder Name",
                  hintText: "John Doe",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _expiryController,
                decoration: InputDecoration(
                  labelText: "Expiry Date",
                  hintText: "MM/YY",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                keyboardType: TextInputType.datetime,
                maxLength: 5,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _addCard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Add Card",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
