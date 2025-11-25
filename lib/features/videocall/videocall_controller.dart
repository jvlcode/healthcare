import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:healthcare/features/videocall/agora_service.dart';
import 'package:healthcare/services/videocall_service.dart';

typedef RemoteJoinedCallback = void Function(int uid);
typedef RemoteLeftCallback = void Function(int uid);

class VideoCallController extends ChangeNotifier {
  final String channelName;
  final int uid;

  VideoCallController({required this.uid, required this.channelName});

  final AgoraService agora = AgoraService();

  bool _disposed = false;
  bool _initialized = false;

  int? remoteUid;
  bool isReady = false;
  bool isMuted = false;
  bool isCameraOff = false;
  String videocallId = "";

  String? _currentChannel;
  int? _currentUid;

  // Safe notifier
  void _safeUpdate(VoidCallback fn) {
    if (_disposed) return;
    fn();
    if (!_disposed) notifyListeners();
  }

  // ------------------------------
  // Start Call
  // ------------------------------
  Future<void> startCall({
    RemoteJoinedCallback? onRemoteJoined,
    RemoteLeftCallback? onRemoteLeft,
  }) async {
    if (_disposed) return;

    try {
      _safeUpdate(() {
        remoteUid = null;
        isReady = false;
      });

      // 1️⃣ Fetch Agora Token (quick)
      final res = await VideoCallService().fetchAgoraToken(
        channel: channelName,
        uid: uid,
      );
      final token = res['data']['token'];

      // 2️⃣ Initialize only once
      if (!_initialized) {
        await agora.initialize(
          onUserJoined: (remote) {
            if (_disposed) return;

            agora.engine.setupRemoteVideo(
              VideoCanvas(
                uid: remote,
                renderMode: RenderModeType.renderModeFit,
              ),
            );

            _safeUpdate(() => remoteUid = remote);
            onRemoteJoined?.call(remote);
          },
          onUserLeft: (remote) {
            if (_disposed) return;
            _safeUpdate(() => remoteUid = null);
            onRemoteLeft?.call(remote);
          },
        );
        _initialized = true;
      }

      // 3️⃣ Enable camera and start preview
      await agora.engine.enableVideo();
      await agora.engine.enableLocalVideo(true);
      await agora.engine.startPreview();

      // 4️⃣ Join Agora instantly (no waiting for API)
      await agora.joinChannel(token: token, channel: channelName, uid: uid);

      _safeUpdate(() => isReady = true);

      // 5️⃣ Run backend updates in background
      // _sendCallAcceptanceAsync();
    } catch (e, st) {
      debugPrint("Error starting call: $e");
      debugPrintStack(stackTrace: st);
    }
  }

  // ------------------------------
  // Mute / Camera
  // ------------------------------
  void toggleMute() {
    _safeUpdate(() {
      isMuted = !isMuted;
      agora.muteMic(isMuted);
    });
  }

  void toggleCamera() {
    _safeUpdate(() {
      isCameraOff = !isCameraOff;
      agora.muteCamera(isCameraOff);
    });
  }

  // ------------------------------
  // End Call
  // ------------------------------
  void endCall(String status) {
    try {
      if (videocallId.isNotEmpty) {
        VideoCallService().updateCall(callId: videocallId, status: status);
      }
    } catch (e) {
      debugPrint("Error ending call: $e");
    }
  }

  // ------------------------------
  // Dispose
  // ------------------------------
  @override
  void dispose() {
    _disposed = true;

    // Safety net: leave channel if still connected
    if (_initialized) {
      agora.engine.leaveChannel(); // fire-and-forget
      agora.engine.stopPreview();
      agora.engine.release();
    }

    super.dispose();
  }
}
