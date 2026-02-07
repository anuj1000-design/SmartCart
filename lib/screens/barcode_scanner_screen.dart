import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/app_state_provider.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal, // Changed for continuous scanning
  );

  final FlutterTts flutterTts = FlutterTts();
  bool isContinuousMode = true;
  bool isProcessing = false;
  Set<String> scannedBarcodes = {}; // Track scanned items in session
  List<Map<String, dynamic>> scanHistory = [];
  int itemsScanned = 0;

  // When running in emulators without camera, CameraX may throw on init.
  // Track whether camera is available and gracefully show a placeholder if not.
  bool _cameraAvailable = true;

  @override
  void initState() {
    super.initState();
    _initializeTTS();
    _loadScanHistory();

    // Probe camera availability without letting exceptions crash the app.
    () async {
      try {
        await controller.start();
        await controller.stop();
        setState(() => _cameraAvailable = true);
      } catch (e) {
        debugPrint('Camera initialization failed: $e');
        setState(() => _cameraAvailable = false);
      }
    }();
  }

  Future<void> _initializeTTS() async {
    // Add delay to prevent initialization lag
    await Future.delayed(const Duration(seconds: 2));
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(0.8);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> _loadScanHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('scan_history') ?? '[]';
    setState(() {
      scanHistory = List<Map<String, dynamic>>.from(json.decode(historyJson));
    });
  }

  Future<void> _saveScanHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('scan_history', json.encode(scanHistory));
  }

  Future<void> _speak(String text) async {
    if (isContinuousMode) {
      await flutterTts.speak(text);
    }
  }

  Future<void> _vibrate() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 100);
    }
  }

  @override
  void dispose() {
    try {
      controller.dispose();
    } catch (e) {
      debugPrint('Controller dispose failed: $e');
    }
    flutterTts.stop();
    super.dispose();
  }

  void _onBarcodeDetect(BarcodeCapture capture) {
    if (isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    if (barcode.rawValue == null || barcode.rawValue!.isEmpty) return;

    final barcodeValue = barcode.rawValue!;

    // Prevent duplicate scans in continuous mode
    if (isContinuousMode && scannedBarcodes.contains(barcodeValue)) {
      return;
    }

    setState(() => isProcessing = true);
    _processBarcode(barcodeValue);
  }

  Future<void> _processBarcode(String barcodeValue) async {
    try {
      // Search for product in Firestore by barcode
      final querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('barcode', isEqualTo: barcodeValue)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // Product not found
        await _speak("Item not found in store");
        await _vibrate();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('❌ Item not found in store'),
              duration: const Duration(seconds: 1),
              backgroundColor: AppTheme.statusWarning,
            ),
          );
        }

        // Add to scan history as not found
        _addToScanHistory(barcodeValue, null, false);
        setState(() => isProcessing = false);
        return;
      }

      // Product found
      final productDoc = querySnapshot.docs.first;
      final data = productDoc.data();

      // Create product from Firestore data
      final product = Product(
        id: productDoc.id,
        name: data['name'] ?? '',
        category: data['category'] ?? 'other',
        brand: data['brand'] ?? '',
        description: data['description'] ?? '',
        price: (data['price'] ?? 0).toDouble().toInt(),
        barcode: data['barcode'] ?? '',
        imageEmoji: data['imageEmoji'] ?? '📦',
        color: AppTheme.darkCardHover,
        stockQuantity: (data['stockQuantity'] ?? 0).toInt(),
      );

      // Add to cart
      if (mounted) {
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        appState.addToCart(product, context: context);

        // Mark as scanned in this session
        scannedBarcodes.add(barcodeValue);
        itemsScanned++;

        // Voice feedback
        await _speak("${product.name} added to cart");
        await _vibrate();

        // Add to scan history
        _addToScanHistory(barcodeValue, product.name, true);

        if (!isContinuousMode) {
          // Navigate back after delay in single mode
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        }
      }
    } catch (e) {
      await _speak("Error scanning item");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('❌ Error processing barcode'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppTheme.statusError,
          ),
        );
      }
    } finally {
      setState(() => isProcessing = false);
    }
  }

  void _addToScanHistory(String barcode, String? productName, bool success) {
    final scanEntry = {
      'barcode': barcode,
      'productName': productName,
      'success': success,
      'timestamp': DateTime.now().toIso8601String(),
    };

    setState(() {
      scanHistory.insert(0, scanEntry);
      // Keep only last 50 scans
      if (scanHistory.length > 50) {
        scanHistory = scanHistory.sublist(0, 50);
      }
    });

    _saveScanHistory();
  }

  void _toggleScanMode() {
    setState(() {
      isContinuousMode = !isContinuousMode;
      scannedBarcodes.clear(); // Reset for new mode
    });

    _speak(isContinuousMode ? "Continuous scan mode" : "Single scan mode");
  }

  void _clearScanHistory() {
    setState(() {
      scanHistory.clear();
      scannedBarcodes.clear();
      itemsScanned = 0;
    });
    _saveScanHistory();
    _speak("Scan history cleared");
  }

  void _showScanHistory(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: Row(
          children: [
            const Text(
              'Scan History',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            const Spacer(),
            if (scanHistory.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _clearScanHistory();
                },
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: AppTheme.statusError),
                ),
              ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: scanHistory.isEmpty
              ? const Center(
                  child: Text(
                    'No scan history yet',
                    style: TextStyle(color: AppTheme.textTertiary),
                  ),
                )
              : ListView.builder(
                  itemCount: scanHistory.length,
                  itemBuilder: (context, index) {
                    final scan = scanHistory[index];
                    final timestamp = DateTime.parse(scan['timestamp']);
                    final timeAgo = _getTimeAgo(timestamp);

                    return ListTile(
                      leading: Icon(
                        scan['success'] ? Icons.check_circle : Icons.error,
                        color: scan['success']
                            ? AppTheme.statusSuccess
                            : AppTheme.statusError,
                      ),
                      title: Text(
                        scan['productName'] ?? 'Unknown Product',
                        style: const TextStyle(color: AppTheme.textPrimary),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Code: ${scan['barcode']}',
                            style: const TextStyle(
                              color: AppTheme.textTertiary,
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                          Text(
                            timeAgo,
                            style: const TextStyle(
                              color: AppTheme.textTertiary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      dense: true,
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showSampleBarcodes(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text(
          'Sample Barcodes',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scan these barcodes to test:',
              style: TextStyle(color: AppTheme.textTertiary),
            ),
            const SizedBox(height: 16),
            _buildSampleBarcode('Organic Bananas', '123456789012'),
            _buildSampleBarcode('Artisan Bread', '234567890123'),
            _buildSampleBarcode('Almond Milk', '345678901234'),
            _buildSampleBarcode('Avocados (3pk)', '456789012345'),
            _buildSampleBarcode('Greek Yogurt', '567890123456'),
            _buildSampleBarcode('Laundry Pods', '678901234567'),
            _buildSampleBarcode('Red Apples', '789012345678'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSampleBarcode(String productName, String barcode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              productName,
              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
            ),
          ),
          Text(
            barcode,
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showManualCodeEntry(BuildContext context) async {
    final codeController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text(
          'Enter Barcode Code',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: codeController,
            style: const TextStyle(color: AppTheme.textPrimary),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter barcode code',
              hintStyle: TextStyle(
                color: AppTheme.textSecondary.withValues(alpha: 0.8),
              ),
              filled: true,
              fillColor: AppTheme.darkCardHover,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.primary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.primary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.primary, width: 2),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a barcode code';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textTertiary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.statusSuccess,
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx, codeController.text);
              }
            },
            child: const Text(
              'Submit',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      _processBarcode(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scan Product Barcode',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 18),
            ),
            Text(
              isContinuousMode
                  ? 'Continuous Mode • $itemsScanned items'
                  : 'Single Mode',
              style: TextStyle(
                color: isContinuousMode
                    ? AppTheme.statusSuccess
                    : AppTheme.primary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Scan mode toggle
          IconButton(
            icon: Icon(
              isContinuousMode ? Icons.repeat : Icons.looks_one,
              color: isContinuousMode
                  ? AppTheme.statusSuccess
                  : AppTheme.primary,
            ),
            onPressed: _toggleScanMode,
            tooltip: isContinuousMode
                ? 'Switch to Single Mode'
                : 'Switch to Continuous Mode',
          ),
          // Scan history
          IconButton(
            icon: Badge(
              label: Text(scanHistory.length.toString()),
              child: const Icon(Icons.history, color: AppTheme.textPrimary),
            ),
            onPressed: () => _showScanHistory(context),
            tooltip: 'Scan History',
          ),
          // Sample barcodes
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppTheme.textPrimary),
            onPressed: () => _showSampleBarcodes(context),
            tooltip: 'Sample Barcodes',
          ),
          // Flash toggle
          IconButton(
            icon: Icon(
              controller.torchEnabled ? Icons.flash_on : Icons.flash_off,
              color: AppTheme.textPrimary,
            ),
            onPressed: () async {
              try {
                await controller.toggleTorch();
              } catch (e) {
                debugPrint('Torch toggle failed: $e');
              }
            },
            tooltip: 'Toggle Flash',
          ),
          // Camera switch
          IconButton(
            icon: const Icon(
              Icons.flip_camera_ios,
              color: AppTheme.textPrimary,
            ),
            onPressed: () async {
              try {
                await controller.switchCamera();
              } catch (e) {
                debugPrint('Switch camera failed: $e');
              }
            },
            tooltip: 'Switch Camera',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view
          _cameraAvailable
              ? MobileScanner(
                  controller: controller,
                  onDetect: _onBarcodeDetect,
                )
              : Container(
                  height: 300,
                  color: AppTheme.darkCard,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 48,
                            color: AppTheme.textTertiary,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Camera unavailable on this device/emulator. Please use a physical device or configure the emulator with a camera to enable scanning.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.textTertiary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          // Scanning overlay
          CustomPaint(
            painter: ScannerOverlay(),
            child: const SizedBox.expand(),
          ),
          // Processing indicator
          if (isProcessing)
            Container(
              color: AppTheme.darkBg.withValues(alpha: 0.7),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              ),
            ),
          // Instructions
          Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: AppTheme.darkBg.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isContinuousMode
                          ? 'Scan multiple items • Voice feedback enabled'
                          : 'Scan one item at a time',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (isContinuousMode && itemsScanned > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '$itemsScanned items scanned this session',
                          style: const TextStyle(
                            color: AppTheme.statusSuccess,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Action buttons
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Manual entry button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.statusSuccess,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => _showManualCodeEntry(context),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit, color: AppTheme.textPrimary),
                        SizedBox(width: 8),
                        Text(
                          'Enter Code Manually',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Clear history button (only show if there's history)
                if (scanHistory.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppTheme.statusError.withValues(
                          alpha: 0.1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _clearScanHistory,
                      child: const Text(
                        'Clear Scan History',
                        style: TextStyle(
                          color: AppTheme.statusError,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaWidth = size.width * 0.7;
    final double scanAreaHeight = size.height * 0.3;
    final double left = (size.width - scanAreaWidth) / 2;
    final double top = (size.height - scanAreaHeight) / 2;

    // Draw darkened background
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final scanAreaPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, scanAreaWidth, scanAreaHeight),
          const Radius.circular(12),
        ),
      );

    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      scanAreaPath,
    );

    canvas.drawPath(
      overlayPath,
      Paint()..color = AppTheme.darkBg.withValues(alpha: 0.7),
    );

    // Draw scanning frame
    final framePaint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, scanAreaWidth, scanAreaHeight),
      const Radius.circular(12),
    );
    canvas.drawRRect(rect, framePaint);

    // Draw corner accents
    final cornerPaint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    const cornerLength = 30.0;

    // Top-left corner
    canvas.drawLine(
      Offset(left, top),
      Offset(left + cornerLength, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top),
      Offset(left, top + cornerLength),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(left + scanAreaWidth, top),
      Offset(left + scanAreaWidth - cornerLength, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaWidth, top),
      Offset(left + scanAreaWidth, top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left, top + scanAreaHeight),
      Offset(left + cornerLength, top + scanAreaHeight),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top + scanAreaHeight),
      Offset(left, top + scanAreaHeight - cornerLength),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(left + scanAreaWidth, top + scanAreaHeight),
      Offset(left + scanAreaWidth - cornerLength, top + scanAreaHeight),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaWidth, top + scanAreaHeight),
      Offset(left + scanAreaWidth, top + scanAreaHeight - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
