class UserModel {
  final int id;
  final String admissionNumber;
  final String email;
  final String fullName;
  final String department;
  final String year;
  final String section;
  final String rollNumber;
  final String role;
  final String avatarUrl;
  final bool isSimVerified;

  UserModel({
    required this.id,
    required this.admissionNumber,
    required this.email,
    required this.fullName,
    required this.department,
    required this.year,
    required this.section,
    required this.rollNumber,
    required this.role,
    required this.avatarUrl,
    required this.isSimVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      admissionNumber: json['admission_number'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? 'GL Bajaj Student',
      department: json['department'] ?? 'Computer Science & Engineering',
      year: json['year'] ?? '3rd Year',
      section: json['section'] ?? 'A',
      rollNumber: json['roll_number'] ?? '',
      role: json['role'] ?? 'student',
      avatarUrl: json['avatar_url'] ?? '',
      isSimVerified: json['is_sim_verified'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'admission_number': admissionNumber,
      'email': email,
      'full_name': fullName,
      'department': department,
      'year': year,
      'section': section,
      'roll_number': rollNumber,
      'role': role,
      'avatar_url': avatarUrl,
      'is_sim_verified': isSimVerified,
    };
  }
}
