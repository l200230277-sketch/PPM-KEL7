/// Base URL for Django REST API.
///
/// - Android emulator: http://10.0.2.2:8000
/// - iOS simulator / desktop: http://127.0.0.1:8000
/// - Physical device: use your PC LAN IP, e.g. http://192.168.1.10:8000
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static String get apiRoot => '$baseUrl/api';
}
