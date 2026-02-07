import 'dart:developer' as developer;

class PerformanceMonitor {
  final Map<String, Stopwatch> _timers = {};

  void startTimer(String operation) {
    _timers[operation] = Stopwatch()..start();
    developer.log('Started timer for: $operation');
  }

  void stopTimer(String operation) {
    final timer = _timers[operation];
    if (timer != null) {
      timer.stop();
      final elapsed = timer.elapsedMilliseconds;
      developer.log('Timer stopped for: $operation - ${elapsed}ms');
      _timers.remove(operation);
    }
  }

  void logPerformance(String operation, int milliseconds) {
    developer.log('Performance: $operation took ${milliseconds}ms');
  }
}
