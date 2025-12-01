class   AirlineStatisticsModel {
  final String airlineId;
  final String airlineName;
  final int totalSubmissions;
  final int pass;
  final int fail;
  final int totalAssessments;
  final double successRate;
  final List<String> assessments;

  AirlineStatisticsModel({
    required this.airlineId,
    required this.airlineName,
    required this.totalSubmissions,
    required this.pass,
    required this.fail,
    required this.totalAssessments,
    required this.successRate,
    required this.assessments,
  });

  // Factory constructor to create an instance from JSON
  factory AirlineStatisticsModel.fromJson(Map<String, dynamic> json) {
    return AirlineStatisticsModel(
      airlineId: json['airlineId'] as String,
      airlineName: json['airlineName'] as String,
      totalSubmissions: json['totalSubmissions'] as int,
      pass: json['pass'] as int,
      fail: json['fail'] as int,
      totalAssessments: json['totalAssessments'] as int,
      successRate: (json['successRate'] as num).toDouble(), // Convert successRate to double
      assessments: List<String>.from(json['assessments'] as List), // Convert list of assessments
    );
  }

  // Convert instance to JSON if needed
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'airlineId': airlineId,
      'airlineName': airlineName,
      'totalSubmissions': totalSubmissions,
      'pass': pass,
      'fail': fail,
      'totalAssessments': totalAssessments,
      'successRate': successRate,
      'assessments': assessments,
    };
  }

  @override
  String toString() {
    return 'AirlineStatisticsModel(airlineId: $airlineId, airlineName: $airlineName, totalSubmissions: $totalSubmissions, pass: $pass, fail: $fail, totalAssessments: $totalAssessments, successRate: $successRate, assessments: $assessments)';
  }
}
