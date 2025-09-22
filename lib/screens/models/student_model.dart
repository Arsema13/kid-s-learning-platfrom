class StudentModel {
  final String id;
  final String name;
  final int level;
  final String email;

  StudentModel({
    required this.id,
    required this.name,
    required this.level,
    required this.email,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map, String id) {
    return StudentModel(
      id: id,
      name: map['name'] ?? '',
      level: map['level'] ?? 1,
      email: map['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'level': level,
      'email': email,
    };
  }
}
