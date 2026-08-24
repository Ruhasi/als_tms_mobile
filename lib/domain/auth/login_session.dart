class LoginSession {
  const LoginSession({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.refreshExpiresIn,
    required this.username,
    required this.roles,
  });

  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final int refreshExpiresIn;
  final String username;
  final List<String> roles;

  factory LoginSession.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    return LoginSession(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      expiresIn: json['expiresIn'] as int? ?? 0,
      refreshExpiresIn: json['refreshExpiresIn'] as int? ?? 0,
      username: user['username'] as String? ?? '',
      roles: List<String>.from(user['roles'] as List? ?? const []),
    );
  }
}
