class ConnectionCodeModel {
  final String code;
  final int ttlSeconds;

  const ConnectionCodeModel({
    required this.code,
    required this.ttlSeconds,
  });

  factory ConnectionCodeModel.fromJson(Map<String, dynamic> json) => ConnectionCodeModel(
        code: json['code'] as String,
        ttlSeconds: (json['ttlSeconds'] as num).toInt(),
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'ttlSeconds': ttlSeconds,
      };

  Duration get ttlDuration => Duration(seconds: ttlSeconds);

  DateTime get expiresAt => DateTime.now().add(ttlDuration);
}