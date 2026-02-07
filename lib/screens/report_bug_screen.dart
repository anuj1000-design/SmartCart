import 'package:flutter/material.dart';
import '../widgets/ui_components.dart';

class ReportBugScreen extends StatefulWidget {
  const ReportBugScreen({super.key});

  @override
  State<ReportBugScreen> createState() => _ReportBugScreenState();
}

class _ReportBugScreenState extends State<ReportBugScreen> {
  final _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the issue')),
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
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 12),
            Text(
              "Report Sent",
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color
              ),
            ),
          ],
        ),
        content: Text(
          "Thanks for your feedback! We'll look into this issue right away.",
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
            child: const Text("Done"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Report a Bug"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bug_report_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Spot a bug?",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.titleLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Describe what went wrong so we can fix it.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            Text(
              "What happened?",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "I was trying to add an item to cart when...",
                alignLabelWithHint: true,
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              "Your Email (Optional)",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: "alerts@example.com",
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            
            const SizedBox(height: 32),
            
            PrimaryButton(
              label: "Submit Report",
              onPressed: _submitReport,
              isLoading: _isSubmitting,
              icon: Icons.send_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
