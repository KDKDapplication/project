enum role {
  PARENT,
  CHILD,
}

class Profile {
  final role r;
  final String? email;
  final String uuid;
  final String? name;
  final String? profileImageUrl;
  final int? age;
  final DateTime? birthdate;
  final bool? isConnected;

  const Profile({
    required this.r,
    this.email,
    required this.uuid,
    this.name,
    this.profileImageUrl,
    this.age,
    this.birthdate,
    this.isConnected,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      r: role.values.firstWhere((e) => e.name == json['role']),
      email: json['email'],
      uuid: json['uuid'],
      name: json['name'],
      profileImageUrl: json['profileImageUrl'],
      age: json['age'],
      birthdate: json['birthdate'] != null ? DateTime.parse(json['birthdate']) : null,
      isConnected: json['isConnected'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': r.name,
      'email': email,
      'uuid': uuid,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'age': age,
      'birthdate': birthdate?.toIso8601String(),
    };
  }

  Profile copyWith({
    role? r,
    String? email,
    String? uuid,
    String? name,
    String? profileImageUrl,
    int? age,
    DateTime? birthdate,
  }) {
    return Profile(
      r: r ?? this.r,
      email: email ?? this.email,
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      age: age ?? this.age,
      birthdate: birthdate ?? this.birthdate,
    );
  }

  @override
  String toString() {
    return 'Profile(r: $r, email: $email, uuid: $uuid, name: $name, profileImageUrl: $profileImageUrl, age: $age, birthdate: $birthdate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Profile &&
        other.r == r &&
        other.email == email &&
        other.uuid == uuid &&
        other.name == name &&
        other.profileImageUrl == profileImageUrl &&
        other.age == age &&
        other.birthdate == birthdate;
  }

  @override
  int get hashCode {
    return r.hashCode ^
        email.hashCode ^
        uuid.hashCode ^
        name.hashCode ^
        profileImageUrl.hashCode ^
        age.hashCode ^
        birthdate.hashCode;
  }
}
