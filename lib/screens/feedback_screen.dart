import 'package:flutter/material.dart';
import '../widgets/ui_components.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _feedbackController = TextEditingController();
  int _selectedRating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.pink),
            const SizedBox(width: 12),
            Text(
              "Thank You!",
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color
              ),
            ),
          ],
        ),
        content: Text(
          "We appreciate your feedback. It helps us build a better app for you.",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingStar(int index) {
    final isSelected = index <= _selectedRating;
    return GestureDetector(
      onTap: () => setState(() => _selectedRating = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Icon(
          isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 40,
          color: isSelected ? Colors.amber : Theme.of(context).disabledColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Send Feedback"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            Text(
              "How is your experience?",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Rate your experience with SmartCart",
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => _buildRatingStar(index + 1)),
            ),
            const SizedBox(height: 40),
            
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Tell us more (Optional)",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "What do you love? What can we do better?",
                alignLabelWithHint: true,
              ),
            ),
            
            const SizedBox(height: 32),
            
            PrimaryButton(
              label: "Submit Feedback",
              onPressed: _submitFeedback,
              isLoading: _isSubmitting,
              icon: Icons.send_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
