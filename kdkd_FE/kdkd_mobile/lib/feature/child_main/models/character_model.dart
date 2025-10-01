// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CharacterModel {
  final String characterName;
  final int experience;
  final int level;
  final String? characterImage;
  CharacterModel({
    required this.characterName,
    required this.experience,
    required this.level,
    this.characterImage,
  });

  CharacterModel copyWith({
    String? characterName,
    int? experience,
    int? level,
    String? characterImage,
  }) {
    return CharacterModel(
      characterName: characterName ?? this.characterName,
      experience: experience ?? this.experience,
      level: level ?? this.level,
      characterImage: characterImage ?? this.characterImage,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'characterName': characterName,
      'experience': experience,
      'level': level,
      'characterImage': characterImage,
    };
  }

  factory CharacterModel.fromMap(Map<String, dynamic> map) {
    return CharacterModel(
      characterName: map['characterName'] as String,
      experience: map['experience'] as int,
      level: map['level'] as int,
      characterImage: map['characterImage'] != null ? map['characterImage'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CharacterModel.fromJson(String source) => CharacterModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'CharacterModel(characterName: $characterName, experience: $experience, level: $level, characterImage: $characterImage)';
  }

  @override
  bool operator ==(covariant CharacterModel other) {
    if (identical(this, other)) return true;

    return other.characterName == characterName &&
        other.experience == experience &&
        other.level == level &&
        other.characterImage == characterImage;
  }

  @override
  int get hashCode {
    return characterName.hashCode ^ experience.hashCode ^ level.hashCode ^ characterImage.hashCode;
  }
}
