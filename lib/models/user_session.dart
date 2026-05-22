class UserSession {
  const UserSession({
    required this.token,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isAdmin,
  });

  final String token;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final bool isAdmin;

  String get displayName {
    final full = [firstName, lastName].where((e) => e.trim().isNotEmpty).join(' ');
    return full.isNotEmpty ? full : username;
  }

  factory UserSession.fromJson(Map<String, dynamic> json, String token) {
    final user = json['user'] as Map<String, dynamic>? ?? json;
    return UserSession(
      token: token,
      username: user['username'] as String? ?? '',
      email: user['email'] as String? ?? '',
      firstName: user['first_name'] as String? ?? '',
      lastName: user['last_name'] as String? ?? '',
      isAdmin: user['is_admin'] as bool? ?? false,
    );
  }

  UserSession copyWith({
    String? email,
    String? firstName,
    String? lastName,
  }) {
    return UserSession(
      token: token,
      username: username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isAdmin: isAdmin,
    );
  }
}
