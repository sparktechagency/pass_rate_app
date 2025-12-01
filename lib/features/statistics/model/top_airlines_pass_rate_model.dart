class TopAirlineByPassRateModel {
  final String airlineName;
  final double successRate;

  TopAirlineByPassRateModel({required this.airlineName, required this.successRate});

  // Factory constructor to create an instance from JSON
  factory TopAirlineByPassRateModel.fromJson(Map<String, dynamic> json) {
    return TopAirlineByPassRateModel(
      airlineName: json['name'] as String? ?? 'Unknown',
      // Handle null with default value
      successRate: double.parse(json['successRate'].toString()), // Handle null with default value
    );
  }

  // Convert instance to JSON if needed
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'airlineName': airlineName, 'totalSubmissions': successRate};
  }

  @override
  String toString() {
    return 'TopAirlineByPassRateModel(airlineName: $airlineName, totalSubmissions: $successRate)';
  }
}
