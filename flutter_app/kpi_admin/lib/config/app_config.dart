// lib/config/app_config.dart
//
// Application-wide configuration constants.

class AppConfig {
  /// Parser-Service Endpoint — Firebase Cloud Run (europe-west3 / Frankfurt).
  /// Verarbeitet Scorecard-PDFs, POD-Quality-PDFs und Concessions-XLSX.
  /// 100% DSGVO-konform (EU-Region).
  static const parserUrl =
      'https://parser-service-641293967282.europe-west3.run.app/parse';
}

// Legacy: https://score-parser.onrender.com  (Render, US-Region — abgeschaltet)
// Local dev: http://127.0.0.1:8080
