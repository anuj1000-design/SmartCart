import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// A widget that detects phone shakes and triggers a callback.
class ShakeListener extends StatefulWidget {
  final Widget child;
  final VoidCallback onShake;
  final double threshold;
  final Duration debounceDuration;

  const ShakeListener({
    super.key,
    required this.child,
    required this.onShake,
    this.threshold = 12.0, // Lowered threshold for better detection
    this.debounceDuration = const Duration(seconds: 2),
  });

  @override
  State<ShakeListener> createState() => _ShakeListenerState();
}

class _ShakeListenerState extends State<ShakeListener> {
  StreamSubscription? _accelerometerSubscription;
  DateTime? _lastShakeTime;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void _startListening() {
    // Using accelerometerEventStream (includes gravity) as it's often more reliable
    // across different devices than userAccelerometer.
    // We calculate delta from gravity (approx 9.8).
    _accelerometerSubscription = accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen((AccelerometerEvent event) {
      // Calculate total acceleration magnitude
      double acceleration = sqrt(
        event.x * event.x + 
        event.y * event.y + 
        event.z * event.z
      );

      // Gravity is ~9.8. We look for spikes above normal gravity + threshold
      // Or simply raw magnitude > (9.8 + threshold)
      if (acceleration > (9.8 + widget.threshold)) {
        final now = DateTime.now();
        if (_lastShakeTime == null || 
            now.difference(_lastShakeTime!) > widget.debounceDuration) {
          _lastShakeTime = now;
          debugPrint("Shake detected! Force: $acceleration");
          widget.onShake();
        }
      }
    }, onError: (e) {
      debugPrint("Shake detection error: $e");
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
