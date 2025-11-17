import 'package:flutter/material.dart';
import 'package:healthcare/features/videocall/agora_service.dart';
import 'package:healthcare/services/videocall_service.dart';

class VideoCallController extends ChangeNotifier {
  final AgoraService agora = AgoraService();
  final VideoCallService _videoCallService = VideoCallService();

  int? remoteUid;
  bool isMuted = false;
  bool isCameraOff = false;

  // Call tracking
  String? _callId;
  bool isBackingUp = false;
  bool isBackedUp = false;
  bool isReady = false; // engine initialized

  /// Initialize engine, fetch token, create backend call, join channel
  Future<void> startCall({
    required String appointmentId,
    required String doctorId,
    required String patientId,
    required String channelName,
    String uid = "0",
  }) async {
    try {
      // 1️⃣ Fetch token
      final res = await _videoCallService.fetchAgoraToken(
        channel: channelName,
        uid: uid,
      );
      final data = res['data'];
      final token = data["token"];

      // 2️⃣ Create backend call record
      final callData = await _videoCallService.startCall(
        appointmentId: appointmentId,
        doctorId: doctorId,
        patientId: patientId,
        channelName: channelName,
      );
      _callId = callData["data"]["_id"];

      // 3️⃣ Initialize Agora engine
      await agora.initialize(
        onUserJoined: (uid) {
          remoteUid = uid;
          notifyListeners();
        },
        onUserLeft: (uid) {
          remoteUid = null;
          notifyListeners();
        },
      );

      // 4️⃣ Join channel
      await agora.joinChannel(token: token, channel: channelName);

      isReady = true;
      notifyListeners();
    } catch (e, stack) {
      debugPrint("Error starting call: $e");
      debugPrint("Error stack: $stack");
    }
  }

  /// Toggle microphone
  void toggleMute() {
    isMuted = !isMuted;
    agora.muteMic(isMuted);
    notifyListeners();
  }

  /// Toggle camera
  void toggleCamera() {
    isCameraOff = !isCameraOff;
    agora.muteCamera(isCameraOff);
    notifyListeners();
  }

  /// End call and update backend
  Future<void> endCall({String? videoUrl}) async {
    if (_callId != null) {
      isBackingUp = true;
      notifyListeners();

      try {
        await _videoCallService.endCall(
          callId: _callId!,
          isBackupAvailable: videoUrl != null,
          videoUrl: videoUrl,
        );
        isBackedUp = videoUrl != null;
      } catch (e) {
        debugPrint("Error ending call: $e");
      } finally {
        isBackingUp = false;
        notifyListeners();
      }
    }

    await agora.dispose();
  }
}
