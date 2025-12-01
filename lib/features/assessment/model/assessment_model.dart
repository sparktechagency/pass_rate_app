class Assessment {
  final String id;
  final String name;

  Assessment({
    required this.id,
    required this.name,
  });

  // Factory constructor to create object from JSON
  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }

  // Convert object back to JSON
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
    };
  }

  @override
  String toString() => 'Category(id: $id, name: $name)';
}
