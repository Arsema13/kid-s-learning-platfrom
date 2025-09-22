class StudentModel {
  final String id;
  final String kidName;
  final String email;
  final int level;

  StudentModel({
    required this.id,
    required this.kidName,
    required this.email,
    required this.level,
  });

  factory StudentModel.fromMap(Map<String, dynamic> map, String docId) {
    return StudentModel(
      id: docId,
      kidName: map['kidName'] ?? '',
      email: map['email'] ?? '',
      level: map['level'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'kidName': kidName,
      'email': email,
      'level': level,
    };
  }
}
