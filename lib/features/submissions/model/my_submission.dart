class MySubmissionModel {
  final String id;
  final String deviceId;
  final DateTime selectedYear;
  final String status;
  final String airline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> assessments;

  MySubmissionModel({
    required this.id,
    required this.deviceId,
    required this.selectedYear,
    required this.status,
    required this.airline,
    required this.createdAt,
    required this.updatedAt,
    required this.assessments,
  });

  // Factory constructor to create an instance from JSON
  factory MySubmissionModel.fromJson(Map<String, dynamic> json) {
    return MySubmissionModel(
      id: json['id'] as String,
      deviceId: json['deviceId'] as String,
      selectedYear: DateTime.parse(json['selectedYear'] as String),
      status: json['status'] as String,
      airline: json['airline'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      assessments: List<String>.from(json['assessments'] as List),
    );
  }

  // Convert the instance to a JSON map
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'deviceId': deviceId,
      'selectedYear': selectedYear.toIso8601String(),
      'status': status,
      'airline': airline,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'assessments': assessments,
    };
  }

  @override
  String toString() {
    return 'SubmissionDataModel(id: $id, deviceId: $deviceId, selectedYear: $selectedYear, status: $status, airline: $airline, createdAt: $createdAt, updatedAt: $updatedAt, assessments: $assessments)';
  }
}
