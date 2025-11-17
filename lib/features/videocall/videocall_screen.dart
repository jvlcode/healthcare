import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:healthcare/features/videocall/videocall_controller.dart';
import 'package:healthcare/features/videocall/config.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class VideoCallScreen extends StatelessWidget {
  final String doctorId;
  final String patientId;
  final String appointmentId;

  const VideoCallScreen({
    super.key,
    required this.doctorId,
    required this.patientId,
    required this.appointmentId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final controller = VideoCallController();
        controller.startCall(
          appointmentId: appointmentId,
          doctorId: doctorId,
          patientId: patientId,
          channelName: AgoraConfig.channel,
        );
        return controller;
      },
      child: _VideoCallView(),
    );
  }
}

class _VideoCallView extends StatelessWidget {
  const _VideoCallView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<VideoCallController>();

    if (!c.isReady) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote video
          Positioned.fill(
            child: c.remoteUid != null
                ? AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: c.agora.engine,
                      canvas: VideoCanvas(uid: c.remoteUid),
                      connection: const RtcConnection(
                        channelId: AgoraConfig.channel,
                      ),
                    ),
                  )
                : const Center(
                    child: Text(
                      "Waiting for other user...",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ),

          // Local video preview
          Positioned(
            right: 20,
            top: 60,
            child: SizedBox(
              width: 120,
              height: 160,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: c.agora.engine,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                ),
              ),
            ),
          ),

          // Backup indicator
          if (c.isBackingUp || c.isBackedUp)
            Positioned(
              top: 30,
              left: 20,
              child: Row(
                children: [
                  Icon(
                    c.isBackingUp ? Icons.cloud_upload : Icons.cloud_done,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    c.isBackingUp ? "Backing up..." : "Backup completed",
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

          // Controls
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _bottomButton(
                  icon: c.isMuted ? Icons.mic_off : Icons.mic,
                  onTap: c.toggleMute,
                ),
                const SizedBox(width: 22),
                _bottomButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  onTap: () async {
                    await c.endCall();
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 22),
                _bottomButton(
                  icon: c.isCameraOff ? Icons.videocam_off : Icons.videocam,
                  onTap: c.toggleCamera,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black54,
        ),
        child: Icon(icon, size: 28, color: color),
      ),
    );
  }
}
