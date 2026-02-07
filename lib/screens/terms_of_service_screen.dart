import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Terms of Service"),
        backgroundColor: Colors.transparent,
      ),
      body: ScreenFade(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              "Terms of Service",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Last updated: February 6, 2026",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Please read these Terms of Service (\"Terms\", \"Terms of Service\") carefully before using the SmartCart mobile application (the \"Service\") operated by SmartCart (\"us\", \"we\", or \"our\"). Your access to and use of the Service is conditioned on your acceptance of and compliance with these Terms. These Terms apply to all visitors, users, and others who access or use the Service.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              "1. Accounts",
              "When you create an account with us, you must provide us information that is accurate, complete, and current at all times. Failure to do so constitutes a breach of the Terms, which may result in immediate termination of your account on our Service. You are responsible for safeguarding the password that you use to access the Service and for any activities or actions under your password.",
            ),
            _buildSection(
              context,
              "2. User Conduct",
              "By using the Service, you agree not to submit content that is unlawful, defamatory, libelous, threatening, harassing, hateful, racially or ethnically offensive, or encourages conduct that would be considered a criminal offense, give rise to civil liability, violate any law, or is otherwise inappropriate.",
            ),
            _buildSection(
              context,
              "3. Product Information and Pricing",
              "We attempt to be as accurate as possible. However, we do not warrant that product descriptions or other content of this site is accurate, complete, reliable, current, or error-free. Prices and availability of products are subject to change without notice. We reserve the right to limit the quantity of items purchased and to correct any errors, inaccuracies, or omissions.",
            ),
            _buildSection(
              context,
              "4. Intellectual Property",
              "The Service and its original content, features, and functionality are and will remain the exclusive property of SmartCart and its licensors. The Service is protected by copyright, trademark, and other laws of both the country and foreign countries.",
            ),
            _buildSection(
              context,
              "5. Modifications to Service",
              "We reserve the right to modify or discontinue, temporarily or permanently, the Service (or any part thereof) with or without notice. We shall not be liable to you or to any third party for any modification, price change, suspension or discontinuance of the Service.",
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}
