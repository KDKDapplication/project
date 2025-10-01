enum UserRole { parent, child }

class SignUpModel {
  final UserRole? userRole;
  final String? name;
  final String? phone;
  final String? birthDate;
  final String? profileImagePath;

  const SignUpModel({
    this.userRole,
    this.name,
    this.phone,
    this.birthDate,
    this.profileImagePath,
  });

  SignUpModel copyWith({
    UserRole? userRole,
    String? name,
    String? phone,
    String? birthDate,
    String? profileImagePath,
  }) {
    return SignUpModel(
      userRole: userRole ?? this.userRole,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userRole': userRole?.name,
      'name': name,
      'phone': phone,
      'birthDate': birthDate,
      'profileImagePath': profileImagePath,
    };
  }

  @override
  String toString() {
    return 'SignUpModel(userRole: $userRole, name: $name, phone: $phone, birthDate: $birthDate, profileImagePath: $profileImagePath)';
  }
}
