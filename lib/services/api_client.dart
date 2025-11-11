import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = "http://192.168.1.5:4000/api/v1";

  final Map<String, String> defaultHeaders = {
    "Content-Type": "application/json",
  };

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse("$baseUrl/$path");

    try {
      final res = await http.post(
        uri,
        headers: defaultHeaders,
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

  Future<Map<String, dynamic>> get(String path) async {
    final uri = Uri.parse("$baseUrl/$path");

    try {
      final res = await http.get(uri, headers: defaultHeaders);
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
