import '../core/constants/api_constants.dart';

class UserModel {
  final int id;
  final String admissionNumber;
  final String email;
  final String fullName;
  final String department;
  final String year;
  final String semester;
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
    required this.semester,
    required this.section,
    required this.rollNumber,
    required this.role,
    required this.avatarUrl,
    required this.isSimVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    String avatar = json['avatar_url'] ?? '';
    if (avatar.isNotEmpty) {
      avatar = ApiConstants.resolveUrl(avatar);
    }
    return UserModel(
      id: json['id'] ?? 0,
      admissionNumber: json['admission_number'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? 'GL Bajaj Student',
      department: json['department'] ?? 'Computer Science & Engineering',
      year: json['year'] ?? '3rd Year',
      semester: json['semester'] ?? '5th Semester',
      section: json['section'] ?? 'A',
      rollNumber: json['roll_number'] ?? '',
      role: json['role'] ?? 'student',
      avatarUrl: avatar,
      isSimVerified: json['is_sim_verified'] ?? true,
    );
  }

  UserModel copyWith({
    int? id,
    String? admissionNumber,
    String? email,
    String? fullName,
    String? department,
    String? year,
    String? semester,
    String? section,
    String? rollNumber,
    String? role,
    String? avatarUrl,
    bool? isSimVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      admissionNumber: admissionNumber ?? this.admissionNumber,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      department: department ?? this.department,
      year: year ?? this.year,
      semester: semester ?? this.semester,
      section: section ?? this.section,
      rollNumber: rollNumber ?? this.rollNumber,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isSimVerified: isSimVerified ?? this.isSimVerified,
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
      'semester': semester,
      'section': section,
      'roll_number': rollNumber,
      'role': role,
      'avatar_url': avatarUrl,
      'is_sim_verified': isSimVerified,
    };
  }
}
