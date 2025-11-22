import 'package:flutter/material.dart';
import 'package:healthcare/core/utils/toast_util.dart';
import 'package:healthcare/services/videocall_service.dart';
import 'package:provider/provider.dart';
import 'package:healthcare/features/videocall/videocall_controller.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class VideoCallScreen extends StatefulWidget {
  final String doctorId;
  final String patientId;
  final String appointmentId;
  final bool isDoctor;
  final String? videocallId;

  const VideoCallScreen({
    super.key,
    required this.doctorId,
    required this.patientId,
    required this.appointmentId,
    required this.isDoctor,
    this.videocallId,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late final VideoCallController _controller;
  final service = VideoCallService();
  @override
  void initState() {
    super.initState();
    _controller = VideoCallController(
      appointmentId: widget.appointmentId,
      doctorId: widget.doctorId,
      patientId: widget.patientId,
      channelName: "appointment_${widget.appointmentId}",
      isDoctor: widget.isDoctor,
      videocallId: widget.videocallId,
    );
    _controller.startCall(
      onRemoteJoined: (uid) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.isDoctor ? "Patient joined!" : "Doctor joined!",
              ),
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    await _controller.endCall();
    ToastUtil.show("You have left the Videocall");
    final callId = _controller.videocallId;
    if (callId != null && callId.isNotEmpty) {
      await service.endCall(callId: callId);
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: WillPopScope(onWillPop: _onWillPop, child: _VideoCallView()),
    );
  }
}

class _VideoCallView extends StatefulWidget {
  const _VideoCallView({super.key});

  @override
  State<_VideoCallView> createState() => _VideoCallViewState();
}

class _VideoCallViewState extends State<_VideoCallView> {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VideoCallController>();

    if (!controller.isReady) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final waitingMessage = controller.isDoctor
        ? "Waiting for the patient to join..."
        : "Waiting for the doctor to join...";

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote video
          Positioned.fill(
            child: controller.remoteUid != null
                ? AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: controller.agora.engine,
                      canvas: VideoCanvas(uid: controller.remoteUid!),
                      connection: RtcConnection(
                        channelId: controller.channelName,
                      ),
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 16),
                        Text(
                          waitingMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          // Local preview
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
                    rtcEngine: controller.agora.engine,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                ),
              ),
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
                  icon: controller.isMuted ? Icons.mic_off : Icons.mic,
                  onTap: controller.toggleMute,
                ),
                const SizedBox(width: 22),
                _bottomButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  onTap: () async {
                    Navigator.maybePop(
                      context,
                    ); // This will trigger willPop internally
                  },
                ),
                const SizedBox(width: 22),
                _bottomButton(
                  icon: controller.isCameraOff
                      ? Icons.videocam_off
                      : Icons.videocam,
                  onTap: controller.toggleCamera,
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
