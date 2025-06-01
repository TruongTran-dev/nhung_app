class RefreshTokenModel {
  final String accessToken;
  final String refreshToken;
  final String accessTokenExpired;

  RefreshTokenModel({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpired,
  });

  factory RefreshTokenModel.fromJson(Map<String, dynamic> json) =>
      RefreshTokenModel(
        accessToken: json["accessToken"],
        refreshToken: json["refreshToken"],
        accessTokenExpired: json["expiredAccessDate"],
      );

  @override
  String toString() {
    return 'RefreshTokenModel{accessToken: $accessToken, refreshToken: $refreshToken, accessTokenExpired: $accessTokenExpired}';
  }
}
