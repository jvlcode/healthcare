import 'dart:async';
import 'package:healthcare/models/call_payload_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:healthcare/app/session/session_manager.dart';
import 'package:healthcare/core/constants/urls.dart';

class SocketEvents {
  static const CHAT_MESSAGE = "chat:message";
  static const CHAT_DELIVERED = "chat:delivered";

  static const CALL_STARTED = "call:started";
  static const CALL_RINGING = "call:ringing";
  static const CALL_IN_PROGRESS = "call:in_progress";
  static const CALL_ENDED = "call:ended";
  static const CALL_DISCONNECTED = "call:disconnected";
  static const CALL_FAILED = "call:failed";
  static const CALL_COMPLETED = "call:completed";
  static const CALL_ACCEPTED = "call:accepted";
  static const CALL_REJECTED = "call:rejected";
  static const CALL_TIMEOUT = "call:timeout";
  static const CALL_MISSED = "call:missed";

  static const APPOINTMENT_UPDATE = "appointment:update";
  static const APPOINTMENT_UPDATED = "appointment:updated";
}

class SocketService {
  IO.Socket? _socket;
  bool _connected = false;
  bool get isConnected => _connected;
  String userId = '';
  // Add this line 👇
  IO.Socket? get socket => _socket;

  /// Singleton
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  /// Streams for listeners
  final StreamController<dynamic> _callEventController =
      StreamController.broadcast();
  Stream<dynamic> get onCallEvent => _callEventController.stream;

  /// Initialize and Connect Socket
  Future<void> init() async {
    if (_connected) return;

    final user = await SessionManager.getCurrentUser();
    if (user == null) {
      throw Exception("No logged-in user.");
    }

    final completer = Completer<void>();
    userId = user.id;
    final query = {"userId": userId};

    _socket = IO.io(
      AppUrls.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setQuery(query) // pass only one map
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      _connected = true;
      print("⚡ Socket Connected");

      _registerCoreEvents();

      if (!completer.isCompleted) completer.complete();
    });

    _socket!.onConnectError((data) {
      print("❌ Socket connect error: $data");

      if (!completer.isCompleted) {
        completer.completeError(data);
      }
    });

    _socket!.onDisconnect((_) {
      _connected = false;
      print("⚠ Disconnected");
    });

    return completer.future;
  }

  /// Private: Register all incoming event listeners
  void _registerCoreEvents() {
    final callEvents = [
      SocketEvents.CHAT_MESSAGE,
      SocketEvents.CALL_STARTED,
      SocketEvents.CALL_RINGING,
      SocketEvents.CALL_IN_PROGRESS,
      SocketEvents.CALL_ENDED,
      SocketEvents.CALL_DISCONNECTED,
      SocketEvents.CALL_FAILED,
      SocketEvents.CALL_COMPLETED,
      SocketEvents.CALL_ACCEPTED,
      SocketEvents.CALL_REJECTED,
      SocketEvents.CALL_TIMEOUT,
      SocketEvents.CALL_MISSED,
    ];

    for (var event in callEvents) {
      _socket!.on(event, (data) {
        print("📨 Incoming socket event: $event");
        _callEventController.add({"event": event, "data": data});
      });
    }
  }

  void emit(String event, Map<String, dynamic> payload) {
    /// Emit events safely
    ///
    if (!_connected || _socket == null) {
      print("⚠ Cannot emit. Socket not connected.");
      return;
    }
    if (payload['fromUserId'] == null) {
      payload['fromUserId'] = userId;
    }
    print("[$event] $payload");
    _socket!.emit(event, payload);
  }

  /// Close/cleanup
  void dispose() {
    _socket?.dispose();
    _callEventController.close();
    _connected = false;
  }
}
