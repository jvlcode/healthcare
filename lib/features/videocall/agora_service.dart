import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:healthcare/features/videocall/config.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  // SINGLETON ENGINE (VERY IMPORTANT)
  static final RtcEngine _engine = createAgoraRtcEngine();
  RtcEngine get engine => _engine;

  Future<void> initialize({
    required Function(int uid) onUserJoined,
    required Function(int uid) onUserLeft,
  }) async {
    // Request permissions FIRST
    await [Permission.camera, Permission.microphone].request();
    await _engine.initialize(RtcEngineContext(appId: AgoraConfig.appId));

    await _engine.enableVideo();
    await _engine.enableAudio();
    // await _engine.setEnableSpeakerphone(true);
    // await _engine.enableDualStreamMode(enabled: true);

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int uid) {
          debugPrint("LOCAL JOINED: $uid");
          _engine.startPreview(); // Start here
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("REMOTE JOINED: $remoteUid");
          onUserJoined(remoteUid);
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              debugPrint("REMOTE LEFT: $remoteUid");
              onUserLeft(remoteUid);
            },
      ),
    );
  }

  Future<void> joinChannel({
    required String token,
    required String channel,
    required int uid,
  }) async {
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
  }

  Future<void> muteMic(bool mute) async {
    await _engine.muteLocalAudioStream(mute);
  }

  Future<void> muteCamera(bool mute) async {
    await _engine.muteLocalVideoStream(mute);
  }

  Future<void> dispose() async {
    await _engine.leaveChannel();

    // DO NOT RELEASE STATIC ENGINE
  }
}
