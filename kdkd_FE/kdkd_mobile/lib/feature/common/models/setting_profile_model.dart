class SettingProfileModel {
  final String name;
  final DateTime birthDate;
  final String? profileImageUrl;
  final bool isValid;

  const SettingProfileModel({
    required this.name,
    required this.birthDate,
    this.profileImageUrl,
    required this.isValid,
  });

  factory SettingProfileModel.initial() {
    return SettingProfileModel(
      name: '',
      birthDate: DateTime.now(),
      profileImageUrl: null,
      isValid: false,
    );
  }

  SettingProfileModel copyWith({
    String? name,
    DateTime? birthDate,
    String? profileImageUrl,
    bool? isValid,
  }) {
    return SettingProfileModel(
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isValid: isValid ?? this.isValid,
    );
  }

  bool get canSave => name.isNotEmpty;

  @override
  String toString() {
    return 'SettingProfileModel(name: $name,  birthDate: $birthDate, profileImageUrl: $profileImageUrl, isValid: $isValid)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingProfileModel &&
        other.name == name &&
        other.birthDate == birthDate &&
        other.profileImageUrl == profileImageUrl &&
        other.isValid == isValid;
  }

  @override
  int get hashCode {
    return name.hashCode ^ birthDate.hashCode ^ profileImageUrl.hashCode ^ isValid.hashCode;
  }
}
