import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:healthcare/models/call_payload_model.dart';
import 'package:healthcare/services/socket_service.dart';
import 'package:healthcare/core/utils/toast_util.dart';
import 'package:healthcare/features/videocall/videocall_controller.dart';

class VideoCallScreen extends StatefulWidget {
  final String doctorId;

  final String patientId;
  final String appointmentId;
  final bool isDoctor;
  final String? callerName;
  final bool isIncoming;
  final VoidCallback onPopCallback;

  const VideoCallScreen({
    super.key,
    required this.doctorId,
    required this.patientId,
    required this.appointmentId,
    required this.isDoctor,
    required this.onPopCallback,
    this.callerName,
    this.isIncoming = false,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late final VideoCallController _controller;
  AudioPlayer? _audioPlayer;
  Timer? _timeoutTimer;

  bool _remoteJoined = false;
  bool _callAnswered = false;
  bool _isDisconnected = false;
  bool _isMissed = false;
  bool _hasEnded = false;

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

    if (widget.isIncoming && !widget.isDoctor) {
      _startRingtone();
    } else {
      _startCall();
    }

    _initSocketListeners();
  }

  @override
  void dispose() {
    _stopRingtone();
    _controller.dispose();
    super.dispose();
  }

  // -------------------------
  // SOCKET EVENTS
  // -------------------------
  Future<void> _initSocketListeners() async {
    await SocketService().init();
    final eventsMap = {
      SocketEvents.CALL_REJECTED: "Call rejected by the other user",
      SocketEvents.CALL_ENDED: "Call ended",
      SocketEvents.CALL_DISCONNECTED: "Call disconnected",
      SocketEvents.CALL_COMPLETED: "Call ended",
      SocketEvents.CALL_FAILED: "Call failed",
      SocketEvents.CALL_TIMEOUT: "Call timout",
      SocketEvents.CALL_MISSED: "Call missed",
    };

    SocketService().onCallEvent.listen((event) {
      final type = event["event"];
      if (eventsMap.containsKey(type))
        _handleEnd(type, eventsMap[type]!, isRemoteEvent: true);
    });
  }

  // -------------------------
  // CALL EVENTS
  // -------------------------
  void _startCall() {
    _controller.startCall(
      onRemoteJoined: _onRemoteJoined,
      onRemoteLeft: _onRemoteLeft,
    );
    _startJoinTimeout();
  }

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
    Future.delayed(const Duration(seconds: 3), () {
      if (!_remoteJoined)
        _handleEnd("CALL_DISCONNECTED", "User dropped the call");
    });
  }

  // -------------------------
  // RINGTONE & TIMEOUT
  // -------------------------
  void _startRingtone() {
    _audioPlayer ??= AudioPlayer()..setReleaseMode(ReleaseMode.loop);
    _audioPlayer!.play(AssetSource('sounds/ringtone.mp3'));
  }

  void _stopRingtone() {
    _audioPlayer?.stop();
    _timeoutTimer?.cancel();
  }

  void _startJoinTimeout() {
    _timeoutTimer = Timer(const Duration(seconds: 30), () {
      if (_remoteJoined) return;
      _isMissed = true;
      _handleEnd("CALL_MISSED", "Call not answered");
    });
  }

  // -------------------------
  // END CALL LOGIC
  // -------------------------
  Future<void> _handleEnd(
    String status,
    String message, {
    bool isRemoteEvent = false,
  }) async {
    if (_hasEnded) return;
    _hasEnded = true;

    _stopRingtone();
    // _controller.endCall(status);

    // Only emit to server if this was a local action
    if (!isRemoteEvent) {
      SocketService().emit(
        status,
        CallPayload(
          callerId: _controller.doctorId,
          receiverId: _controller.patientId,
          appointmentId: _controller.appointmentId,
        ).toJson(),
      );
    }

    widget.onPopCallback();
    if (mounted && Navigator.canPop(context)) Navigator.pop(context);
  }

  void _answerCall() {
    setState(() => _callAnswered = true);
    _stopRingtone();
    _startCall();
  }

  void _rejectCall() =>
      _handleEnd(SocketEvents.CALL_REJECTED, "You rejected the call");

  Future<void> _onWillPop(didPop, result) async {
    if (didPop) return;
    if (_isMissed)
      return _handleEnd(SocketEvents.CALL_MISSED, "Call not answered");
    if (_isDisconnected)
      return _handleEnd(
        SocketEvents.CALL_DISCONNECTED,
        "User dropped the call",
      );

    final shouldEnd = await _confirmHangup();
    if (shouldEnd == true)
      _handleEnd(SocketEvents.CALL_DISCONNECTED, "Call Disconnected");
  }

  Future<bool?> _confirmHangup() => showDialog<bool>(
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

  // -------------------------
  // BUILD
  // -------------------------
  @override
  Widget build(BuildContext context) {
    if (widget.isIncoming && !_callAnswered && !widget.isDoctor)
      return _buildIncomingUI();

    return ChangeNotifierProvider.value(
      value: _controller,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: _onWillPop,
        child: _VideoCallView(remoteJoined: _remoteJoined),
      ),
    );
  }

  Widget _buildIncomingUI() {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.call, color: Colors.green, size: 70),
            const SizedBox(height: 24),
            Text(
              widget.callerName ?? "Caller",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "is calling you...",
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _incomingBtn(
                  Icons.call_end,
                  "Decline",
                  Colors.red,
                  _rejectCall,
                ),
                _incomingBtn(Icons.call, "Answer", Colors.green, _answerCall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _incomingBtn(
    IconData icon,
    String text,
    Color color,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: CircleAvatar(
            radius: 32,
            backgroundColor: color,
            child: Icon(icon, size: 28, color: Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(text, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

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
            controller.isMuted ? Icons.mic_off : Icons.mic,
            controller.toggleMute,
          ),
          const SizedBox(width: 22),
          _controlBtn(
            Icons.call_end,
            () => Navigator.maybePop(context),
            Colors.red,
          ),
          const SizedBox(width: 22),
          _controlBtn(
            controller.isCameraOff ? Icons.videocam_off : Icons.videocam,
            controller.toggleCamera,
          ),
        ],
      ),
    );
  }

  Widget _controlBtn(
    IconData icon,
    VoidCallback onTap, [
    Color color = Colors.white,
  ]) {
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
