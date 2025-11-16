import 'package:flutter/material.dart';
import 'package:healthcare/services/auth_service.dart';

class NetworkHelper {
  // Singleton instance
  static final NetworkHelper _instance = NetworkHelper._internal();

  // Factory constructor
  factory NetworkHelper() => _instance;

  // Private constructor
  NetworkHelper._internal();

  // AuthService singleton
  final AuthService _authService = AuthService();

  /// Executes an API call safely
  ///
  /// [apiCall] is the API function that returns a Map<String, dynamic>
  /// [onSuccess] is called if the API returns success == true
  /// [onApiError] is called if the API returns success == false
  /// [onException] is called if the API throws an exception
  Future<T?> safeCall<T>(
    BuildContext context,
    Future<T> Function() apiCall, {
    void Function(T result)? onSuccess,
    void Function(T result)? onApiError,
    void Function(Object e)? onException,
  }) async {
    try {
      // 1️⃣ Check server reachability
      final reachable = await _authService.isServerReachable();
      if (!reachable) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Server Unreachable")));
        }
        return null;
      }

      // 2️⃣ Perform API call
      final result = await apiCall();

      // 3️⃣ Handle success or API-level error
      if (result is Map<String, dynamic> && result['success'] == true) {
        if (onSuccess != null) onSuccess(result);
      } else {
        if (onApiError != null) {
          onApiError(result);
        } else if (context.mounted) {
          final message = (result is Map && result['message'] != null)
              ? result['message']
              : "Unknown error";
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message.toString())));
        }
      }

      return result;
    } catch (e) {
      // 4️⃣ Handle exceptions
      if (onException != null) {
        onException(e);
      } else if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
      return null;
    }
  }
}
