import 'package:flutter/material.dart';
import 'package:healthcare/app/session/reachability_controller.dart';
import 'package:healthcare/app/session/session_manager.dart';
import 'package:healthcare/services/auth_service.dart';
import 'package:provider/provider.dart';

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
      final reachable = await _authService.isServerReachable();

      if (context.mounted) {
        context.read<ReachabilityController>().updateReachability(reachable);
      }

      if (!reachable) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Server Unreachable")));
        }
        return null;
      }

      T result = await apiCall();
      print("RESULT");
      print(result);
      // Handle expired token (backend usually returns 401 or a specific flag)
      if (result is Map<String, dynamic> &&
          (result['success'] == false &&
              result['message'] == 'TOKEN_EXPIRED')) {
        final refreshed = await SessionManager.refreshAccessToken();
        // Try refreshing token
        if (refreshed) {
          // Retry original call with new token
          result = await apiCall();
        }
      }

      if (result is Map<String, dynamic> &&
          (result['success'] == false &&
              result['message'] == 'TOKEN_EXPIRED')) {
        result['message'] = "Session expired. Please login again.";
      }
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
    } catch (e, stackTrace) {
      print('Exception: $e');
      print('Stack trace: $stackTrace');

      if (onException != null) {
        onException(e.toString());
      } else if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
      }
      return null;
    }
  }
}
