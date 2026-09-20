import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final telemetryServiceProvider = Provider((ref) => TelemetryService());

/// Simple telemetry service to record identification metrics.
/// In a production environment, this would post to an analytics endpoint (e.g. Mixpanel, Firebase Analytics, PostHog).
class TelemetryService {
  void logIdentification({
    required String provider,
    required int latencyMs,
    required bool success,
    required double confidence,
    required bool isUserCorrected,
    required bool isSaved,
  }) {
    // In a real app, send to analytics service.
    // For now, log to console.
    debugPrint(
      '[Telemetry] Identification Event:\n'
      '  Provider: $provider\n'
      '  Latency: ${latencyMs}ms\n'
      '  Success: $success\n'
      '  Confidence: ${(confidence * 100).toStringAsFixed(1)}%\n'
      '  User Corrected: $isUserCorrected\n'
      '  Saved: $isSaved'
    );
  }
}
