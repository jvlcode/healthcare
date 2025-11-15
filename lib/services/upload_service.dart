import 'dart:io';
import 'api_client.dart';

class UploadService {
  final ApiClient _apiClient = ApiClient();

  /// -------------------------------
  /// UPLOAD DOCUMENT (MULTIPART)
  /// -------------------------------
  ///
  /// Backend response:
  /// {
  ///   "url": "/uploads/1763222458766-33308.png"
  /// }
  ///
  Future<Map<String, dynamic>> uploadDocument(File file) async {
    final res = await _apiClient.postMultipart(
      "file/upload",
      file,
      fieldName: "file",
      useAuth: true,
    );
    if (res["success"] == true) {
      return res["data"]; // returns {"url": "..."}
    } else {
      throw Exception(res["message"] ?? "Upload failed");
    }
  }
}
