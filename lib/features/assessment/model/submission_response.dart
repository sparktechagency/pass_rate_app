class SubmissionResponse {
  final String airlineName;
  final DateTime selectedYear;
  final double totalResponse;
  final double totalSuccessRate;

  SubmissionResponse({
    required this.airlineName,
    required this.selectedYear,
    required this.totalResponse,
    required this.totalSuccessRate,
  });

  /// Factory constructor to parse JSON
  factory SubmissionResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? submission = json['submission'] as Map<String, dynamic>?;

    return SubmissionResponse(
      airlineName: submission?['name'] as String? ?? '',
      selectedYear:
          submission?['date'] != null
              ? DateTime.parse(submission!['date'] as String)
              : DateTime.now(),
      totalResponse: (json['totalResponse'] as num?)?.toDouble() ?? 0.0,
      totalSuccessRate: (json['successRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert back to JSON if needed
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'airlineName': airlineName,
      'selectedYear': selectedYear.toIso8601String(),
      'totalRate': totalResponse,
      'totalSuccessRate': totalSuccessRate,
    };
  }

  @override
  String toString() {
    return 'SubmissionResponse(airlineName: $airlineName, selectedYear: $selectedYear, totalRate: $totalResponse, totalSuccessRate: $totalSuccessRate)';
  }
}
