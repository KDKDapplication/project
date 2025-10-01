class LoginRequest {
  final String email, password;
  const LoginRequest({required this.email, required this.password});
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

abstract class AuthModel {
  const AuthModel();
}

class ExistingUserAuth extends AuthModel {
  final String accessToken;
  final String refreshToken;
  final String userUuid;
  final int expiresIn;

  const ExistingUserAuth({
    required this.accessToken,
    required this.refreshToken,
    required this.userUuid,
    required this.expiresIn,
  });

  factory ExistingUserAuth.fromJson(Map<String, dynamic> json) {
    return ExistingUserAuth(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      userUuid: json['userUuid'],
      expiresIn: json['expiresIn'],
    );
  }
}

class NewUserAuth extends AuthModel {
  final bool onboardingRequired;
  final String signupToken;
  final bool newUser;

  const NewUserAuth({
    required this.onboardingRequired,
    required this.signupToken,
    required this.newUser,
  });

  factory NewUserAuth.fromJson(Map<String, dynamic> json) {
    return NewUserAuth(
      onboardingRequired: json['onboardingRequired'],
      signupToken: json['signupToken'],
      newUser: json['newUser'],
    );
  }
}
