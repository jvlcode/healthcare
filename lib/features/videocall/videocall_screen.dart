import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:healthcare/core/utils/toast_util.dart';
import 'package:healthcare/features/videocall/videocall_controller.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class VideoCallScreen extends StatefulWidget {
  final String doctorId;
  final String patientId;
  final String appointmentId;
  final bool isDoctor;
  final VoidCallback onPopCallback;

  const VideoCallScreen({
    super.key,
    required this.doctorId,
    required this.patientId,
    required this.appointmentId,
    required this.isDoctor,
    required this.onPopCallback,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late final VideoCallController _controller;
  AudioPlayer? _audioPlayer;
  Timer? _timeoutTimer;

  bool _remoteJoined = false;
  bool _isDisconnected = false;
  bool _isMissed = false;

  // -------------------------
  // LIFECYCLE
  // -------------------------
  @override
  void initState() {
    super.initState();

    _controller = VideoCallController(
      appointmentId: widget.appointmentId,
      doctorId: widget.doctorId,
      patientId: widget.patientId,
      channelName: "appointment_${widget.appointmentId}",
      isDoctor: widget.isDoctor,
    );

    _controller.startCall(
      onRemoteJoined: _onRemoteJoined,
      onRemoteLeft: _onRemoteLeft,
    );

    _startRingtone();
    _startJoinTimeout();
  }

  @override
  void dispose() {
    _stopRingtone();
    _controller.dispose();
    super.dispose();
  }

  // -------------------------
  // REMOTE EVENTS
  // -------------------------
  void _onRemoteJoined(int uid) {
    _stopRingtone();
    setState(() {
      _remoteJoined = true;
      _isDisconnected = false;
    });

    ToastUtil.success(widget.isDoctor ? "Patient joined!" : "Doctor joined!");
  }

  void _onRemoteLeft(int uid) {
    setState(() {
      _remoteJoined = false;
      _isDisconnected = true;
    });

    // Small grace time before closing
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_remoteJoined) Navigator.maybePop(context);
    });
  }

  // -------------------------
  // RINGTONE & TIMEOUT
  // -------------------------
  void _startRingtone() async {
    _audioPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.loop);
    await _audioPlayer!.play(AssetSource('sounds/ringtone.mp3'));
  }

  void _stopRingtone() {
    _audioPlayer?.stop();
    _timeoutTimer?.cancel();
  }

  void _startJoinTimeout() {
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (_remoteJoined) return;

      _stopRingtone();
      _isMissed = true;
      if (mounted) Navigator.maybePop(context);
    });
  }

  // -------------------------
  // POP HANDLING
  // -------------------------
  Future<void> _handleEnd(String status, String message) async {
    await _showDialog("Call Ended", message);
    _controller.endCall(status);
    widget.onPopCallback();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _onWillPop(didPop, result) async {
    if (didPop) return;

    if (_isMissed) {
      return _handleEnd("CALL_MISSED", "Call not answered.");
    }

    if (_isDisconnected) {
      return _handleEnd("CALL_DISCONNECTED", "User dropped the call.");
    }

    final shouldEnd = await _confirmHangup();
    if (shouldEnd == true) {
      _stopRingtone();
      _controller.endCall("CALL_DISCONNECTED");
      widget.onPopCallback();
      ToastUtil.show("Call Disconnected");
      if (mounted) Navigator.pop(context);
    }
  }

  // -------------------------
  // DIALOG HELPERS
  // -------------------------
  Future<void> _showDialog(String title, String message) async {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmHangup() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("End Video Call"),
        content: const Text("Are you sure you want to disconnect the call?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // BUILD
  // -------------------------
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: _onWillPop,
        child: _VideoCallView(remoteJoined: _remoteJoined),
      ),
    );
  }
}

// ============================================================================
// UI VIEW (Unchanged Visuals)
// ============================================================================
class _VideoCallView extends StatelessWidget {
  final bool remoteJoined;
  const _VideoCallView({super.key, required this.remoteJoined});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<VideoCallController>();

    if (!controller.isReady) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildRemoteVideo(controller),
          _buildLocalVideo(controller),
          _buildControls(controller, context),
        ],
      ),
    );
  }

  // ---------------------
  // UI HELPERS
  // ---------------------
  Widget _buildRemoteVideo(VideoCallController controller) {
    return Positioned.fill(
      child: remoteJoined && controller.remoteUid != null
          ? AgoraVideoView(
              controller: VideoViewController.remote(
                rtcEngine: controller.agora.engine,
                canvas: VideoCanvas(uid: controller.remoteUid!),
                connection: RtcConnection(channelId: controller.channelName),
              ),
            )
          : const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    "Connecting...",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLocalVideo(VideoCallController controller) {
    return Positioned(
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
    );
  }

  Widget _buildControls(VideoCallController controller, BuildContext context) {
    return Positioned(
      bottom: 30,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _controlBtn(
            icon: controller.isMuted ? Icons.mic_off : Icons.mic,
            onTap: controller.toggleMute,
          ),
          const SizedBox(width: 22),
          _controlBtn(
            icon: Icons.call_end,
            color: Colors.red,
            onTap: () => Navigator.maybePop(context),
          ),
          const SizedBox(width: 22),
          _controlBtn(
            icon: controller.isCameraOff ? Icons.videocam_off : Icons.videocam,
            onTap: controller.toggleCamera,
          ),
        ],
      ),
    );
  }

  Widget _controlBtn({
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
