import 'package:healthcare/services/api_client.dart';

class ChatService {
  final ApiClient _apiClient = ApiClient();

  /// Start chat between the logged in user and another user
  Future<Map<String, dynamic>> startChat({required String otherUserId}) async {
    final body = {"otherUserId": otherUserId};

    final res = await _apiClient.post("chats/start", body, useAuth: true);

    return res;
  }

  /// Fetch messages of a chat
  Future<Map<String, dynamic>> getMessages(String chatId) async {
    final res = await _apiClient.get("chats/$chatId/messages", useAuth: true);
    return res;
  }

  /// Get all user's active chats
  Future<Map<String, dynamic>> getUserChats() async {
    final res = await _apiClient.get("chats", useAuth: true);
    return res;
  }
}
