 class UserModel {
  final String its;
  final String fullName;
  final String mobile;
  final String mohallah;
  final String role;
  final String passwordLast4;
  final DateTime createdAt;

  UserModel({
    required this.its,
    required this.fullName,
    required this.mobile,
    required this.mohallah,
    required this.role,
    required this.passwordLast4,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      its: json['its'] ?? '',
      fullName: json['full_name'] ?? '',
      mobile: json['mobile'] ?? '',
      mohallah: json['mohallah'] ?? '',
      role: json['role'] ?? 'user',
      passwordLast4: json['password_last4'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'its': its,
      'full_name': fullName,
      'mobile': mobile,
      'mohallah': mohallah,
      'role': role,
      'password_last4': passwordLast4,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? its,
    String? fullName,
    String? mobile,
    String? mohallah,
    String? role,
    String? passwordLast4,
    DateTime? createdAt,
  }) {
    return UserModel(
      its: its ?? this.its,
      fullName: fullName ?? this.fullName,
      mobile: mobile ?? this.mobile,
      mohallah: mohallah ?? this.mohallah,
      role: role ?? this.role,
      passwordLast4: passwordLast4 ?? this.passwordLast4,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isSubAdmin => role == 'subadmin';
  bool get isUser => role == 'user';

  String get email => '\$its@swt.com';
}