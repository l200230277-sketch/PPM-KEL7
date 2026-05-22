import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/user_session.dart';

class AuthApiService {
  AuthApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final String _root = '${ApiConfig.apiRoot}/auth';

  Future<UserSession> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$_root/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return UserSession.fromJson(data, data['token'] as String);
  }

  Future<UserSession> login({
    required String username,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$_root/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );
    _ensureSuccess(response);
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return UserSession.fromJson(data, data['token'] as String);
  }

  Future<UserSession> updateProfile({
    required String token,
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    final body = <String, dynamic>{};
    if (firstName != null) body['first_name'] = firstName;
    if (lastName != null) body['last_name'] = lastName;
    if (email != null) body['email'] = email;

    final response = await _client.patch(
      Uri.parse('$_root/me/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: jsonEncode(body),
    );
    _ensureSuccess(response);
    final user = jsonDecode(response.body) as Map<String, dynamic>;
    return UserSession(
      token: token,
      username: user['username'] as String? ?? '',
      email: user['email'] as String? ?? '',
      firstName: user['first_name'] as String? ?? '',
      lastName: user['last_name'] as String? ?? '',
      isAdmin: user['is_admin'] as bool? ?? false,
    );
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = response.body;
      try {
        final err = jsonDecode(response.body) as Map<String, dynamic>;
        if (err.containsKey('detail')) {
          message = err['detail'].toString();
        } else if (err.isNotEmpty) {
          message = err.values.first.toString();
        }
      } catch (_) {}
      throw Exception(message);
    }
  }
}
