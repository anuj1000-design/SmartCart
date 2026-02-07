import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class PdfService {
  /// Generate a PDF receipt and save it to the device
  static Future<String?> generateReceipt({
    required String storeName,
    required String storeAddress,
    required String phoneNumber,
    required String email,
    required String exitCode,
    required List<Map<String, dynamic>> items,
    required String paymentMethod,
    required double subtotal,
    required double tax,
    required double total,
    bool letUserChoose = false,
  }) async {
    try {
      // Create PDF document
      final pdf = pw.Document();

      // Generate current date and time
      final now = DateTime.now();
      final dateStr = '${now.day}/${now.month}/${now.year}';
      final timeStr = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

      // Add page to PDF with MultiPage for automatic pagination
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              // Header
              pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.only(bottom: 20),
                child: pw.Column(
                  children: [
                    pw.Text(
                      storeName,
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      storeAddress,
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.Text(
                      'Phone: $phoneNumber',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.Text(
                      'Email: $email',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              pw.Divider(thickness: 2),
              pw.SizedBox(height: 10),

              // Receipt Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Date: $dateStr'),
                  pw.Text('Time: $timeStr'),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Text('Exit Code: $exitCode'),
              pw.SizedBox(height: 20),

              // Items Table Header
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(vertical: 8),
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(width: 1)),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        'Item',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        'Qty',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        'Price',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        'Total',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),

              // Items
              ...items.map((item) {
                final name = item['name'] ?? 'Unknown Item';
                final quantity = item['quantity'] ?? 0;
                final price = item['price'] ?? 0.0;
                final itemTotal = quantity * price;

                return pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 6),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(
                        width: 0.5,
                        color: PdfColors.grey300,
                      ),
                    ),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(flex: 3, child: pw.Text(name)),
                      pw.Expanded(
                        child: pw.Text(
                          quantity.toString(),
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          '₹${price.toStringAsFixed(2)}',
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Text(
                          '₹${itemTotal.toStringAsFixed(2)}',
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              pw.SizedBox(height: 20),

              // Totals
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.SizedBox(width: 100, child: pw.Text('Subtotal:')),
                        pw.SizedBox(
                          width: 80,
                          child: pw.Text(
                            '₹${subtotal.toStringAsFixed(2)}',
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 5),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      children: [
                        pw.SizedBox(width: 100, child: pw.Text('Tax:')),
                        pw.SizedBox(
                          width: 80,
                          child: pw.Text(
                            '₹${tax.toStringAsFixed(2)}',
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 10),
                    pw.Container(
                      padding: const pw.EdgeInsets.only(top: 8),
                      decoration: pw.BoxDecoration(
                        border: pw.Border(top: pw.BorderSide(width: 2)),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.SizedBox(
                            width: 100,
                            child: pw.Text(
                              'Total:',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          pw.SizedBox(
                            width: 80,
                            child: pw.Text(
                              '₹${total.toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: pw.TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Payment Method
              pw.Text('Payment Method: $paymentMethod'),
              pw.SizedBox(height: 20),

              // Exit QR Code
              pw.Container(
                alignment: pw.Alignment.center,
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 1),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'Exit Verification Code',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.BarcodeWidget(
                      data: exitCode,
                      barcode: pw.Barcode.qrCode(),
                      width: 120,
                      height: 120,
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      exitCode,
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Please show this code at the exit gate',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Footer
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Thank you for shopping with us!',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ];
          },
        ),
      );

      // Generate PDF bytes first
      final pdfBytes = await pdf.save();

      // Let user choose save location or use default Downloads
      String? filePath;

      if (letUserChoose) {
        // Let user pick save location
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        String? outputPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save Receipt PDF',
          fileName: 'receipt_$timestamp.pdf',
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );

        if (outputPath != null) {
          final file = File(outputPath);
          await file.writeAsBytes(pdfBytes);
          filePath = outputPath;
        }
      } else {
        // Save to Downloads folder automatically
        Directory? directory;

        if (Platform.isAndroid) {
          // Try to use Downloads directory
          directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            // Fallback to external storage
            final externalDir = await getExternalStorageDirectory();
            if (externalDir != null) {
              // Navigate to public Downloads
              final downloadPath = '/storage/emulated/0/Download';
              directory = Directory(downloadPath);

              if (!await directory.exists()) {
                // Last resort: use app's directory
                directory = Directory('${externalDir.path}/Receipts');
                await directory.create(recursive: true);
              }
            }
          }
        } else if (Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory != null) {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          filePath = '${directory.path}/receipt_$timestamp.pdf';
          final file = File(filePath);
          await file.writeAsBytes(pdfBytes);
        }
      }

      return filePath;
    } catch (e) {
      debugPrint('Error generating PDF: $e');
      return null;
    }
  }
}
