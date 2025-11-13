import 'dart:convert';
import 'package:healthcare/app/session/session_manager.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = "http://192.168.1.5:4000/api/v1";

  final Map<String, String> defaultHeaders = {
    "Content-Type": "application/json",
  };

  // Replace this with your actual token management
  Future<String?> getAuthToken() async {
    return await SessionManager.getAccessToken();
    // return "your_access_token_here";
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool useAuth = false,
  }) async {
    final uri = Uri.parse("$baseUrl/$path");
    final headers = Map<String, String>.from(defaultHeaders);

    if (useAuth) {
      final token = await getAuthToken();
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }
    }

    try {
      final res = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      final data = res.body.isNotEmpty ? jsonDecode(res.body) : {};
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Request failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> get(String path, {bool useAuth = false}) async {
    final uri = Uri.parse("$baseUrl/$path");
    final headers = Map<String, String>.from(defaultHeaders);

    if (useAuth) {
      final token = await getAuthToken();
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }
    }

    try {
      final res = await http.get(uri, headers: headers);
      final data = res.body.isNotEmpty ? jsonDecode(res.body) : {};
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Request failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
