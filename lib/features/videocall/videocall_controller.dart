import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:healthcare/features/videocall/agora_service.dart';
import 'package:healthcare/services/videocall_service.dart';

typedef RemoteJoinedCallback = void Function(int uid);

class VideoCallController extends ChangeNotifier {
  final String appointmentId;
  final String doctorId;
  final String patientId;
  final String channelName;
  final bool isDoctor;
  final String? videocallId;

  VideoCallController({
    required this.appointmentId,
    required this.doctorId,
    required this.patientId,
    required this.channelName,
    required this.isDoctor,
    this.videocallId,
  });

  final AgoraService agora = AgoraService();
  final VideoCallService service = VideoCallService();

  bool _disposed = false;
  bool _initialized = false;

  int? remoteUid;
  bool isReady = false;
  bool isMuted = false;
  bool isCameraOff = false;

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
  Future<void> startCall({RemoteJoinedCallback? onRemoteJoined}) async {
    if (_disposed) return;

    try {
      final uid = isDoctor ? 1001 : 2001;
      _currentUid = uid;
      _currentChannel = channelName;

      _safeUpdate(() {
        remoteUid = null;
        isReady = false;
      });

      final res = await service.fetchAgoraToken(channel: channelName, uid: uid);
      final token = res['data']['token'];

      if (!_initialized) {
        await agora.initialize(
          onUserJoined: (remote) {
            if (_disposed) return;

            // Register remote video
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
          },
        );
        _initialized = true;
      }

      // IMPORTANT STEPS
      await agora.engine.enableVideo();
      await agora.engine.enableLocalVideo(true);
      await agora.engine.startPreview();

      await agora.joinChannel(token: token, channel: channelName, uid: uid);

      _safeUpdate(() => isReady = true);
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
  Future<void> endCall() async {
    if (_disposed) return;

    try {
      if (_initialized) {
        await agora.engine.leaveChannel();
        await agora.engine.stopPreview();
      }

      _safeUpdate(() {
        remoteUid = null;
        isReady = false;
        _currentChannel = null;
        _currentUid = null;
      });
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

    if (_initialized) {
      agora.engine.release(); // Must destroy engine!
    }

    super.dispose();
  }
}
