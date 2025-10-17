class TopAirlineBySubmissionModel {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int submissionCount;

  TopAirlineBySubmissionModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.submissionCount,
  });

  // Factory constructor to create an instance from JSON
  factory TopAirlineBySubmissionModel.fromJson(Map<String, dynamic> json) {
    return TopAirlineBySubmissionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      submissionCount: json['_count']['submissions'] as int, // Fetch the submission count from _count
    );
  }

  // Convert instance to JSON if needed
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '_count': <String, int>{'submissions': submissionCount},  // Save submission count inside _count
    };
  }

  @override
  String toString() {
    return 'TopAirlineBySubmissionModel(id: $id, name: $name, createdAt: $createdAt, updatedAt: $updatedAt, submissionCount: $submissionCount)';
  }
}
