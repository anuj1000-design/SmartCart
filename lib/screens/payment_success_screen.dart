import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/pdf_service.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String orderNumber;
  final String receiptNo;
  final String exitCode;
  final String paymentMethod;
  final double total;

  const PaymentSuccessScreen({
    super.key,
    required this.orderNumber,
    required this.receiptNo,
    required this.exitCode,
    required this.paymentMethod,
    required this.total,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  Future<void> _saveReceiptAsPdf() async {
    try {
      final filePath = await PdfService.generateReceipt(
        storeName: 'SmartCart Store',
        storeAddress: 'SmartCart Store #001',
        phoneNumber: '7020767759',
        email: 'pawarshreyas425@gmail.com',
        exitCode: widget.exitCode,
        items: [], // No items available in this screen
        paymentMethod: widget.paymentMethod,
        subtotal: widget.total,
        tax: 0.0, // No tax calculation available
        total: widget.total,
      );

      if (filePath != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ PDF saved to: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Failed to save PDF'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error saving PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showReceiptDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: theme.cardColor,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: 500,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Payment Receipt',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Receipt header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2E2E2E) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: isDark ? null : Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'SmartCart Store',
                              style: TextStyle(
                                color: theme.textTheme.bodyLarge?.color,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'SmartCart Store #001',
                              style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Receipt #${widget.receiptNo.length >= 8 ? widget.receiptNo.substring(0, 8).toUpperCase() : widget.receiptNo.toUpperCase()}',
                              style: TextStyle(
                                color: isDark ? const Color(0xFFD0E4FF) : Colors.blue[800],
                                fontFamily: 'monospace',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Order #${widget.orderNumber}',
                              style: TextStyle(
                                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Payment details
                      Text(
                        'Payment Details:',
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2E2E2E) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: isDark ? null : Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Payment Method:',
                                  style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                                ),
                                Text(
                                  widget.paymentMethod,
                                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Amount:',
                                  style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                                ),
                                Text(
                                  '₹${widget.total.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: theme.textTheme.bodyLarge?.color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Exit code section
                      Text(
                        'Exit Verification Code:',
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2E2E2E) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: isDark ? null : Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          children: [
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(8),
                                child: QrImageView(
                                  data: widget.exitCode,
                                  version: QrVersions.auto,
                                  size: 120.0,
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                widget.exitCode,
                                style: TextStyle(
                                  color: isDark ? const Color(0xFFD0E4FF) : Colors.blue[800],
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Center(
                              child: Text(
                                'Show this code at the exit gate',
                                style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton.icon(
                      icon: Icon(
                        Icons.picture_as_pdf,
                        color: theme.brightness == Brightness.dark ? Colors.white : theme.primaryColor,
                        size: 18,
                      ),
                      label: Text(
                        'Save PDF',
                        style: TextStyle(
                          color: theme.brightness == Brightness.dark ? Colors.white : theme.primaryColor,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: theme.brightness == Brightness.dark ? Colors.white : theme.primaryColor,
                        ),
                      ),
                      onPressed: _saveReceiptAsPdf,
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Close',
                        style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payment Successful',
          style: TextStyle(color: theme.textTheme.titleLarge?.color),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.iconTheme.color),
      ),
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Success icon
                const Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 16),

                // Success message
                const Text(
                  'Payment Successful!',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  'Payment Method: ${widget.paymentMethod}',
                  style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7), fontSize: 16),
                ),
                const SizedBox(height: 32),

                // Order details card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset:const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // QR Code section
                      Text(
                        'Exit Verification Code',
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // QR Code
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: QrImageView(
                          data: widget.exitCode,
                          version: QrVersions.auto,
                          size: 150.0,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Exit code text
                      Text(
                        widget.exitCode,
                        style: TextStyle(
                          color: isDark ? const Color(0xFFD0E4FF) : Colors.blue[800],
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Order details
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                          border: isDark ? null : Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow('Order Number', widget.orderNumber, context),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              'Receipt ID',
                              widget.receiptNo.substring(0, 8).toUpperCase(),
                              context
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              'Total Amount',
                              '₹${widget.total.toStringAsFixed(2)}',
                              context
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _showReceiptDialog(context),
                              icon: const Icon(Icons.receipt),
                              label: const Text('View Receipt'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? const Color(0xFFD0E4FF) : theme.primaryColor,
                                foregroundColor: isDark ? Colors.black : Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Navigate back to home
                                Navigator.of(
                                  context,
                                ).popUntil((route) => route.isFirst);
                              },
                              icon: const Icon(Icons.home),
                              label: const Text('Back to Home'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2E2E2E) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: isDark ? null : Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '📋 Instructions:',
                        style: TextStyle(
                          color: theme.textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Show this QR code to the exit scanner\n• Keep this code safe for your records\n• Order details are saved in your history',
                        style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7), fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7), fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
