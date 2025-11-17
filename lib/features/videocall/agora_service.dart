import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:healthcare/features/videocall/config.dart';

class AgoraService {
  late final RtcEngine engine;

  /// Initialize Agora engine and register event handlers
  Future<void> initialize({
    required Function(int uid) onUserJoined,
    required Function(int uid) onUserLeft,
  }) async {
    // Create engine
    engine = createAgoraRtcEngine();

    // Initialize engine with App ID
    await engine.initialize(const RtcEngineContext(appId: AgoraConfig.appId));

    // Enable video and start local preview
    await engine.enableVideo();
    await engine.startPreview();

    // Register event handlers
    engine.registerEventHandler(
      RtcEngineEventHandler(
        // Only use 2 parameters if your SDK expects 2
        onJoinChannelSuccess: (RtcConnection connection, int uid) {
          print("Local user joined channel: uid=$uid");
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          print("Remote user joined: $remoteUid");
          onUserJoined(remoteUid);
        },
        onUserOffline: (connection, remoteUid, reason) {
          print("Remote user left: $remoteUid");
          onUserLeft(remoteUid);
        },
      ),
    );
  }

  /// Join a channel with token and channel name
  Future<void> joinChannel({
    required String token,
    required String channel,
    int uid = 0,
  }) async {
    await engine.joinChannel(
      token: token,
      channelId: channel,
      uid: uid,
      options: const ChannelMediaOptions(
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ),
    );
  }

  /// Mute/unmute microphone
  Future<void> muteMic(bool mute) async {
    await engine.muteLocalAudioStream(mute);
  }

  /// Turn camera on/off
  Future<void> muteCamera(bool mute) async {
    await engine.muteLocalVideoStream(mute);
  }

  /// Leave channel and release resources
  Future<void> dispose() async {
    await engine.leaveChannel();
    await engine.release();
  }
}
