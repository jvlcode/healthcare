// lib/core/constants/api_constants.dart
class AppUrls {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const String apiUrl = '$baseUrl/api/v1';
}
