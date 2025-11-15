import 'dart:convert';
import 'dart:io';
import 'package:healthcare/app/session/session_manager.dart';
import 'package:healthcare/core/constants/urls.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ApiClient {
  static const String baseUrl = AppUrls.apiUrl;

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
      print(res.body);
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
      print(e);
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> get(
    String path, {
    bool useAuth = false,
    Map<String, dynamic>? queryParams,
  }) async {
    final uri = Uri.parse("$baseUrl/$path").replace(
      queryParameters: queryParams?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );

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

  Future<Map<String, dynamic>> multipartPut(
    String path, {
    required Map<String, String> fields,
    File? file,
    String fileField = 'profileImage',
    bool useAuth = false,
  }) async {
    final uri = Uri.parse("$baseUrl/$path");
    final request = http.MultipartRequest('PUT', uri);

    if (useAuth) {
      final token = await getAuthToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }

    request.fields.addAll(fields);

    if (file != null) {
      final mimeType = lookupMimeType(file.path) ?? 'image/jpeg';
      final fileStream = http.ByteStream(file.openRead());
      final length = await file.length();

      request.files.add(
        http.MultipartFile(
          fileField,
          fileStream,
          length,
          filename: file.path.split('/').last,
          contentType: MediaType.parse(mimeType),
        ),
      );
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
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

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? data,
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
      final res = await http.patch(
        uri,
        headers: headers,
        body: jsonEncode(data ?? {}),
      );
      final responseData = res.body.isNotEmpty ? jsonDecode(res.body) : {};
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Request failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic>? data, {
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
      final res = await http.put(
        uri,
        headers: headers,
        body: jsonEncode(data ?? {}),
      );

      final responseData = res.body.isNotEmpty ? jsonDecode(res.body) : {};

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Request failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> delete(
    String path, {
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
      final res = await http.delete(uri, headers: headers);
      final responseData = res.body.isNotEmpty ? jsonDecode(res.body) : {};

      if (res.statusCode >= 200 && res.statusCode < 300) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Request failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> postMultipart(
    String path,
    File file, {
    String fieldName = "file",
    bool useAuth = false,
    Map<String, String>? fields,
  }) async {
    final uri = Uri.parse("$baseUrl/$path");

    final request = http.MultipartRequest("POST", uri);

    // Auth header
    if (useAuth) {
      final token = await getAuthToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }

    // Additional form fields
    if (fields != null) {
      request.fields.addAll(fields);
    }

    // Prepare file
    final mimeType = lookupMimeType(file.path) ?? "application/octet-stream";
    final fileStream = http.ByteStream(file.openRead());
    final fileLength = await file.length();

    request.files.add(
      http.MultipartFile(
        fieldName,
        fileStream,
        fileLength,
        filename: file.path.split('/').last,
        contentType: MediaType.parse(mimeType),
      ),
    );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {"success": true, "data": data};
      } else {
        return {
          "success": false,
          "message": data["message"] ?? "Upload failed",
        };
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }
}
