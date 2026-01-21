// File: lib/mock_data.dart
class AnalysisResult {
  final String date;
  final int colonyCount;
  final double maxLength;

  AnalysisResult({required this.date, required this.colonyCount, required this.maxLength});
}

class MockDatabase {
  static List<AnalysisResult> results = [];
} 