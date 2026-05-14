import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:healthcare/features/videocall/config.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  static final RtcEngine _engine = createAgoraRtcEngine();
  RtcEngine get engine => _engine;

  Future<void> initialize({
    required Function(int uid) onUserJoined,
    required Function(int uid) onUserLeft,
  }) async {
    if (!kIsWeb) {
      await [Permission.camera, Permission.microphone].request();
    }

    debugPrint("Initializing Agora engine...");
    await _engine.initialize(RtcEngineContext(appId: AgoraConfig.appId));

    debugPrint("Enabling video + audio...");
    await _engine.enableVideo();
    await _engine.enableAudio();

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int uid) {
          debugPrint(
            "✅ LOCAL JOINED channel=${connection.channelId}, uid=$uid",
          );
          if (!kIsWeb) {
            debugPrint("Starting preview (mobile)...");
            _engine.startPreview();
          }
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("👤 REMOTE JOINED: $remoteUid (elapsed=$elapsed ms)");
          onUserJoined(remoteUid);
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              debugPrint("👤 REMOTE LEFT: $remoteUid (reason=$reason)");
              onUserLeft(remoteUid);
            },
        onConnectionStateChanged:
            (
              RtcConnection connection,
              ConnectionStateType state,
              ConnectionChangedReasonType reason,
            ) {
              debugPrint("🔄 CONNECTION STATE: $state (reason=$reason)");
            },
        onError: (ErrorCodeType err, String msg) {
          debugPrint("❌ AGORA ERROR: $err, message=$msg");
        },
        onLocalVideoStateChanged:
            (
              VideoSourceType source,
              LocalVideoStreamState state,
              LocalVideoStreamReason reason,
            ) {
              debugPrint(
                "📹 LOCAL VIDEO STATE: source=$source, state=$state, reason=$reason",
              );
            },
        onRemoteVideoStateChanged:
            (
              RtcConnection connection,
              int remoteUid,
              RemoteVideoState state,
              RemoteVideoStateReason reason,
              int elapsed,
            ) {
              debugPrint(
                "📹 REMOTE VIDEO STATE: uid=$remoteUid, state=$state, reason=$reason",
              );
            },
        onLocalAudioStateChanged:
            (
              RtcConnection connection,
              LocalAudioStreamState state,
              LocalAudioStreamReason reason,
            ) {
              debugPrint("🎤 LOCAL AUDIO STATE: state=$state, reason=$reason");
            },
      ),
    );
  }

  Future<void> joinChannel({
    required String token,
    required String channel,
    required int uid,
  }) async {
    debugPrint("Joining channel=$channel with uid=$uid...");
    await _engine.joinChannel(
      token: token,
      channelId: channel,
      uid: uid,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        autoSubscribeVideo: true,
        autoSubscribeAudio: true,
      ),
    );

    if (kIsWeb) {
      debugPrint("Starting preview (web)...");
      await _engine.startPreview();

      debugPrint("Enabling local video (web)...");
      await _engine.enableLocalVideo(true);

      debugPrint("Enabling local audio (web)...");
      await _engine.enableLocalAudio(true);
    }
  }

  Future<void> muteMic(bool mute) async {
    debugPrint("Mic mute=$mute");
    await _engine.muteLocalAudioStream(mute);
  }

  Future<void> muteCamera(bool mute) async {
    debugPrint("Camera mute=$mute");
    await _engine.muteLocalVideoStream(mute);
  }

  Future<void> dispose() async {
    debugPrint("Leaving channel...");
    await _engine.leaveChannel();
  }
}
