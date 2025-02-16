class SignInModel {
  final String accessToken;
  final String refreshToken;
  final int id;
  final String username;
  final String email;
  final List<String> roles;
  final String expiredAccessToken;
  final String expiredRefreshToken;

  SignInModel({
    required this.accessToken,
    required this.refreshToken,
    required this.id,
    required this.username,
    required this.email,
    required this.roles,
    required this.expiredAccessToken,
    required this.expiredRefreshToken,
  });

  factory SignInModel.fromJson(Map<String, dynamic> json) {
    return SignInModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((role) => role as String)
              .toList() ??
          [],
      expiredAccessToken: json['expiredAccessDate'] as String,
      expiredRefreshToken: json['expiredRefreshDate'] as String,
    );
  }

  @override
  String toString() {
    return 'SignInModel{accessToken: $accessToken, refreshToken: $refreshToken, id: $id, username: $username, email: $email, roles: $roles, expiredAccessToken: $expiredAccessToken, expiredRefreshToken: $expiredRefreshToken}';
  }
}
