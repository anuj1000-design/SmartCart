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

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with TickerProviderStateMixin {
  final MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back, // Start with rear camera
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

  // Animation controllers for enhanced UI
  late AnimationController _scanLineController;
  late AnimationController _pulseController;
  late Animation<double> _scanLineAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Reset scan state on screen open
    scannedBarcodes.clear();
    itemsScanned = 0;
    isProcessing = false;
    
    _initializeTTS();
    _loadScanHistory();
    _initializeAnimations();

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

  void _initializeAnimations() {
    // Scanning line animation
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanLineController,
        curve: Curves.easeInOut,
      ),
    );

    // Pulse animation for frame
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
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
    // Speak in both modes for better feedback
    await flutterTts.speak(text);
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
    _scanLineController.dispose();
    _pulseController.dispose();
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
        if (mounted) {
          setState(() => isProcessing = false);
        }
        
        // In single mode, close after failed scan too
        if (!isContinuousMode && mounted) {
          Navigator.pop(context);
          return;
        }
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

        // Mark as scanned in continuous mode only
        if (isContinuousMode) {
          scannedBarcodes.add(barcodeValue);
          itemsScanned++;
        }

        // Voice feedback
        await _speak("${product.name} added to cart");
        await _vibrate();

        // Add to scan history
        _addToScanHistory(barcodeValue, product.name, true);

        if (!isContinuousMode) {
          // Navigate back immediately in single mode
          if (mounted) {
            Navigator.pop(context);
          }
          return; // Exit early to prevent finally block
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
      
      // In single mode, close on error too
      if (!isContinuousMode && mounted) {
        Navigator.pop(context);
        return;
      }
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
      }
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
      if (!isContinuousMode) {
        // In single mode, reset processing state to allow immediate scan
        isProcessing = false;
      }
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            border: Border.all(
              color: AppTheme.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scan Product Barcode',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 18),
            ),
            Text(
              isContinuousMode
                  ? 'Continuous • $itemsScanned scanned'
                  : 'Single Scan • Auto-close',
              style: TextStyle(
                color: isContinuousMode
                    ? AppTheme.statusSuccess
                    : AppTheme.accentBlue,
                fontSize: 12,
                fontWeight: FontWeight.w500,
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
          // Flash toggle
          IconButton(
            icon: Icon(
              controller.torchEnabled ? Icons.flash_on : Icons.flash_off,
              color: AppTheme.textPrimary,
            ),
            onPressed: () async {
              try {
                await controller.toggleTorch();
                setState(() {}); // Rebuild to update icon
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
                setState(() {}); // Rebuild after camera switch
              } catch (e) {
                debugPrint('Switch camera failed: $e');
              }
            },
            tooltip: 'Switch Camera',
              ),
            ],
          ),
        ),
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
          // Scanning overlay with animations
          AnimatedBuilder(
            animation: Listenable.merge([_scanLineAnimation, _pulseAnimation]),
            builder: (context, child) {
              return CustomPaint(
                painter: ScannerOverlay(
                  scanLinePosition: _scanLineAnimation.value,
                  pulseScale: _pulseAnimation.value,
                ),
                child: const SizedBox.expand(),
              );
            },
          ),
          // Processing indicator (clean card style)
          if (isProcessing)
            Container(
              color: AppTheme.darkBg.withValues(alpha: 0.85),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppTheme.darkCard,
                    borderRadius: BorderRadius.circular(24), // Match app card radius
                    border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          strokeWidth: 5,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Processing...',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Looking up product',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          // Instructions with glassmorphism
          Positioned(
            bottom: 140,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard,
                  borderRadius: BorderRadius.circular(24), // Match app cards
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mode indicator badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isContinuousMode 
                            ? AppTheme.statusSuccess.withValues(alpha: 0.15)
                            : AppTheme.accentBlue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isContinuousMode 
                              ? AppTheme.statusSuccess.withValues(alpha: 0.3)
                              : AppTheme.accentBlue.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        isContinuousMode ? 'CONTINUOUS MODE' : 'SINGLE SCAN MODE',
                        style: TextStyle(
                          color: isContinuousMode 
                              ? AppTheme.statusSuccess 
                              : AppTheme.accentBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isContinuousMode
                              ? Icons.repeat_rounded
                              : Icons.center_focus_strong_rounded,
                          color: AppTheme.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            isContinuousMode
                                ? 'Scan multiple items continuously'
                                : 'Scans one item and closes automatically',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    if (isContinuousMode && itemsScanned > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.statusSuccess.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.statusSuccess.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppTheme.statusSuccess,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$itemsScanned items scanned',
                                style: const TextStyle(
                                  color: AppTheme.statusSuccess,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
                // Manual entry button (stadium shaped like app buttons)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.textPrimary,
                      shape: const StadiumBorder(),
                      elevation: 4,
                      shadowColor: AppTheme.primary.withValues(alpha: 0.4),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    ),
                    onPressed: () => _showManualCodeEntry(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.keyboard_rounded,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Enter Code Manually',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Clear history button (outlined button style)
                if (scanHistory.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.statusError,
                        side: BorderSide(
                          color: AppTheme.statusError.withValues(alpha: 0.5),
                          width: 1,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: _clearScanHistory,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.delete_sweep_rounded,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Clear Scan History',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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
  final double scanLinePosition;
  final double pulseScale;

  ScannerOverlay({
    this.scanLinePosition = 0.5,
    this.pulseScale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaWidth = size.width * 0.75;
    final double scanAreaHeight = size.height * 0.35;
    final double left = (size.width - scanAreaWidth) / 2;
    final double top = (size.height - scanAreaHeight) / 2;

    // Draw semi-transparent overlay (cleaner, less dark)
    final overlayPaint = Paint()
      ..color = AppTheme.darkBg.withValues(alpha: 0.6);
    
    // Top overlay
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, top),
      overlayPaint,
    );
    // Bottom overlay
    canvas.drawRect(
      Rect.fromLTWH(0, top + scanAreaHeight, size.width, size.height - (top + scanAreaHeight)),
      overlayPaint,
    );
    // Left overlay
    canvas.drawRect(
      Rect.fromLTWH(0, top, left, scanAreaHeight),
      overlayPaint,
    );
    // Right overlay
    canvas.drawRect(
      Rect.fromLTWH(left + scanAreaWidth, top, size.width - (left + scanAreaWidth), scanAreaHeight),
      overlayPaint,
    );

    // Animated scanning line
    final scanLinePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          AppTheme.primary.withValues(alpha: 0.0),
          AppTheme.primary.withValues(alpha: 0.9),
          AppTheme.primary.withValues(alpha: 0.9),
          AppTheme.primary.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.45, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(left, top, scanAreaWidth, 4))
      ..style = PaintingStyle.fill;

    final scanY = top + (scanAreaHeight * scanLinePosition);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, scanY - 2, scanAreaWidth, 4),
        const Radius.circular(2),
      ),
      scanLinePaint,
    );

    // Subtle scan line glow
    final glowPaint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, scanY - 4, scanAreaWidth, 8),
        const Radius.circular(4),
      ),
      glowPaint,
    );

    // Simple rounded corner accents (matching app's 24px radius style)
    final cornerPaint = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4 * pulseScale
      ..strokeCap = StrokeCap.round;

    final cornerLength = 32.0 * pulseScale;
    final cornerRadius = 24.0; // Match app card radius

    // Top-left corner
    canvas.drawLine(
      Offset(left + cornerRadius, top),
      Offset(left + cornerLength, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top + cornerRadius),
      Offset(left, top + cornerLength),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(left + scanAreaWidth - cornerRadius, top),
      Offset(left + scanAreaWidth - cornerLength, top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaWidth, top + cornerRadius),
      Offset(left + scanAreaWidth, top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(left + cornerRadius, top + scanAreaHeight),
      Offset(left + cornerLength, top + scanAreaHeight),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left, top + scanAreaHeight - cornerRadius),
      Offset(left, top + scanAreaHeight - cornerLength),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(left + scanAreaWidth - cornerRadius, top + scanAreaHeight),
      Offset(left + scanAreaWidth - cornerLength, top + scanAreaHeight),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaWidth, top + scanAreaHeight - cornerRadius),
      Offset(left + scanAreaWidth, top + scanAreaHeight - cornerLength),
      cornerPaint,
    );

    // Subtle corner glow (minimal)
    final glowCornerPaint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Apply glow to all corners
    canvas.drawLine(
      Offset(left + cornerRadius, top),
      Offset(left + cornerLength, top),
      glowCornerPaint,
    );
    canvas.drawLine(
      Offset(left, top + cornerRadius),
      Offset(left, top + cornerLength),
      glowCornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaWidth - cornerRadius, top),
      Offset(left + scanAreaWidth - cornerLength, top),
      glowCornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaWidth, top + cornerRadius),
      Offset(left + scanAreaWidth, top + cornerLength),
      glowCornerPaint,
    );
    canvas.drawLine(
      Offset(left + cornerRadius, top + scanAreaHeight),
      Offset(left + cornerLength, top + scanAreaHeight),
      glowCornerPaint,
    );
    canvas.drawLine(
      Offset(left, top + scanAreaHeight - cornerRadius),
      Offset(left, top + scanAreaHeight - cornerLength),
      glowCornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaWidth - cornerRadius, top + scanAreaHeight),
      Offset(left + scanAreaWidth - cornerLength, top + scanAreaHeight),
      glowCornerPaint,
    );
    canvas.drawLine(
      Offset(left + scanAreaWidth, top + scanAreaHeight - cornerRadius),
      Offset(left + scanAreaWidth, top + scanAreaHeight - cornerLength),
      glowCornerPaint,
    );
  }

  @override
  bool shouldRepaint(ScannerOverlay oldDelegate) {
    return oldDelegate.scanLinePosition != scanLinePosition ||
        oldDelegate.pulseScale != pulseScale;
  }
}
