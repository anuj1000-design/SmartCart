import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/ui_components.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privacy Policy"),
        backgroundColor: Colors.transparent,
      ),
      body: ScreenFade(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              "Privacy Policy",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Effective Date: February 6, 2026",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "This Privacy Policy describes how SmartCart (\"we\", \"us\", or \"our\") collects, uses, and discloses your personal information when you use our mobile application (the \"Service\"). By using the Service, you agree to the collection and use of information in accordance with this policy.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              "1. Information Collection and Use",
              "We collect several different types of information for various purposes to provide and improve our Service to you:\n\n"
              "• **Personal Data:** While using our Service, we may ask you to provide us with certain personally identifiable information that can be used to contact or identify you (\"Personal Data\"). Personally identifiable information may include, but is not limited to: Name, Email address, and User Role.\n"
              "• **Usage Data:** We may also collect information that your browser sends whenever you visit our Service or when you access the Service by or through a mobile device (\"Usage Data\"). This may include information such as your device's Internet Protocol address (e.g. IP address), browser type, browser version, the pages of our Service that you visit, the time and date of your visit, the time spent on those pages, unique device identifiers and other diagnostic data.\n"
              "• **Shopping Activity:** We maintain records of your transaction history, saved cart items, and product preferences to facilitate your shopping experience.",
            ),
            _buildSection(
              context,
              "2. Device Permissions",
              "We may request access to specific features on your device to enable core functionality:\n\n"
              "• **Camera:** Access is required solely for the purpose of scanning product barcodes. We do not access your photo library or record video content without your explicit consent.\n"
              "• **Notifications:** We may use push notifications to send you updates regarding your order status and other service-related information.",
            ),
            _buildSection(
              context,
              "3. Information Sharing and Disclosure",
              "We do not sell, trade, or otherwise transfer to outside parties your Personally Identifiable Information. This does not include trusted third parties who assist us in operating our application, conducting our business, or servicing you, so long as those parties agree to keep this information confidential.",
            ),
            _buildSection(
              context,
              "4. Data Security",
              "The security of your data is important to us, but remember that no method of transmission over the Internet, or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your Personal Data, we cannot guarantee its absolute security. We utilize industry-standard authentication and database services provided by Google Firebase.",
            ),
            _buildSection(
              context,
              "5. User Rights",
              "You have the right to request access to, correction of, or deletion of your personal data. You may exercise these rights by contacting our support team via the in-app reporting features.",
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
