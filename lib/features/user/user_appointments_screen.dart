import 'dart:async';

import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';
import 'package:healthcare/core/helpers/network_helper.dart';
import 'package:healthcare/core/utils/image_util.dart';
import 'package:healthcare/core/utils/navigation_util.dart';
import 'package:healthcare/core/utils/toast_util.dart';
import 'package:healthcare/core/widgets/appointment_card.dart';
import 'package:healthcare/core/widgets/network_aware_scaffold.dart';
import 'package:healthcare/core/widgets/safe_avatar.dart';
import 'package:healthcare/features/user/videocall_history_screen.dart';
import 'package:healthcare/features/videocall/videocall_screen.dart';
import 'package:healthcare/models/appointment_model.dart';
import 'package:healthcare/models/call_payload_model.dart';
import 'package:healthcare/services/appoinment_service.dart';
import 'package:healthcare/services/socket_service.dart';
import 'package:healthcare/services/videocall_service.dart';

class UserAppointmentsScreen extends StatefulWidget {
  const UserAppointmentsScreen({super.key});

  @override
  State<UserAppointmentsScreen> createState() => _UserAppointmentsScreenState();
}

class _UserAppointmentsScreenState extends State<UserAppointmentsScreen> {
  List<Appointment> bookings = [];
  bool _loading = true;
  String? _error;
  Timer? _autoRefreshTimer;
  final VideoCallService videocallService = VideoCallService();
  bool _incomingScreenOpened = false;
  final SocketService socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _initSocketListeners();
  }

  Future<void> _initSocketListeners() async {
    await SocketService().init(); // Make sure socket is connected

    SocketService().onCallEvent.listen((event) {
      final type = event["event"];
      final data = event["data"];
      print("📩 Socket event: $type");

      switch (type) {
        case SocketEvents.CALL_RINGING:
          _handleIncomingCall(data);
          break;
      }
    });
  }

  void _handleIncomingCall(dynamic payload) {
    final call = CallPayload.fromJson(payload);

    if (_incomingScreenOpened) return;
    _incomingScreenOpened = true;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PopScope(
          onPopInvokedWithResult: (didPop, result) {
            _incomingScreenOpened = false;
          },
          child: VideoCallScreen(
            appointmentId: call.appointmentId,
            doctorId: call.callerId,
            patientId: call.receiverId,
            isDoctor: false,
            isIncoming: true, // marks this as an incoming call
            callerName: call.doctorName ?? "Caller",
            onPopCallback: () {
              _incomingScreenOpened = false;
            },
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _incomingScreenOpened = false;
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> handleAccept(
    BuildContext context, {
    required String appointmentId,
    required String doctorId,
    required String patientId,
  }) async {
    _incomingScreenOpened = false;
    final payload = CallPayload(
      callerId: patientId,
      receiverId: doctorId,
      appointmentId: appointmentId,
      roomId: "room_${appointmentId}", // optional for Agora/WebRTC
      startTime: DateTime.now().toIso8601String(),
    );

    SocketService().emit(SocketEvents.CALL_ACCEPTED, payload.toJson());
    navigateSlideLeft(
      context,
      page: VideoCallScreen(
        appointmentId: appointmentId,
        doctorId: doctorId,
        patientId: patientId,
        isDoctor: false,
        onPopCallback: () {},
      ),
    );
  }

  Future<void> handleReject(
    BuildContext context, {
    required String appointmentId,
    required String doctorId,
    required String patientId,
  }) async {
    _incomingScreenOpened = false;

    final payload = CallPayload(
      callerId: patientId,
      receiverId: doctorId,
      appointmentId: appointmentId,
      roomId: "room_$appointmentId",
      startTime: DateTime.now().toIso8601String(),
    );

    SocketService().emit(SocketEvents.CALL_REJECTED, payload.toJson());

    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  Future<void> _postCallRejection({
    required String appointmentId,
    required String doctorId,
    required String patientId,
  }) async {
    try {
      final payload = CallPayload(
        callerId: patientId,
        receiverId: doctorId,
        appointmentId: appointmentId,
        roomId: "room_${appointmentId}", // optional for Agora/WebRTC
        startTime: DateTime.now().toIso8601String(),
      );

      SocketService().emit(SocketEvents.CALL_REJECTED, payload.toJson());

      debugPrint("📌 CALL_REJECTED saved successfully.");
    } catch (e) {
      debugPrint("❌ Error saving CALL_REJECTED: $e");
    }
  }

  Future<void> _loadAppointments() async {
    setState(() {
      // _loading = true;
      _error = null;
    });

    try {
      await NetworkHelper().safeCall(
        context,
        () => AppointmentService().getUserAppointments(),
        onSuccess: (res) {
          final data = res['data'] as List;
          bookings = data.map((e) => Appointment.fromJson(e)).toList();
        },
        onApiError: (_) => _error = "Failed to load appointments",
        onException: (e) => _error = e.toString(),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refreshAppointments() async {
    await _loadAppointments();
    ToastUtil.success("Appointments updated!");
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NetworkAwareScaffold(
      loading: _loading,
      error: _error,
      onRetry: _loadAppointments,
      child: _buildUI(),
    );
  }

  String statusText(String status) {
    switch (status.toUpperCase()) {
      case 'CALL_STARTED':
        return "Ringing...";
      case 'CALL_ACCEPTED':
      case 'ONGOING':
        return "Call in progress";
      case 'CALL_REJECTED':
        return "You rejected the call";
      case 'CALL_MISSED':
        return "You missed the call";
      case 'CALL_DISCONNECTED':
        return "Call disconnected";
      case 'COMPLETED':
        return "Completed";
      default:
        return status;
    }
  }

  Widget _renderActions(Appointment booking) {
    final status = booking.status.toUpperCase();

    switch (status) {
      case 'ONGOING':
      case 'CALL_ACCEPTED':
        return Row(
          children: [
            Expanded(
              child: GFButton(
                onPressed: () {
                  navigateSlideLeft(
                    context,
                    page: VideoCallScreen(
                      appointmentId: booking.id!,
                      doctorId: booking.doctor.id,
                      patientId: booking.patient.id,
                      isDoctor: false,
                      onPopCallback: () {},
                    ),
                  );
                },
                text: "Join Call",
                color: Colors.green,
                shape: GFButtonShape.pills,
              ),
            ),
          ],
        );

      // These show no buttons
      case 'PENDING':
      case 'CALL_REJECTED':
      case 'CALL_MISSED':
      case 'COMPLETED':
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildUI() {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F2),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            navigateSlideLeft(context, page: VideoCallHistoryScreen()),
        icon: const Icon(Icons.history, color: Colors.white),
        label: const Text("Video Call History"),
        backgroundColor: const Color(0xFF01312F),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAppointments,
        child: bookings.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Text(
                        _error ?? "No appointments available",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    "Doctor Appointments",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  ...bookings.map((booking) {
                    final statusColor = _statusColor(booking.status);

                    return AppointmentCard(
                      avatar: CircleAvatar(
                        radius: 28,
                        child: SafeAvatar(
                          imageUrl: ImageUtils.resolve(
                            booking.doctor.profileImage,
                          ),
                          size: 120,
                        ),
                      ),
                      title: booking.doctor.application.personalInfo.fullName,
                      subtitle: booking.doctor.specialization,
                      status: statusText(booking.status),
                      statusColor: statusColor,
                      date: booking.slot.dateLabel,
                      timeRange:
                          "${booking.slot.startTimeLabel} - ${booking.slot.endTimeLabel}",
                      actionButtons: _renderActions(booking),
                    );
                  }),
                ],
              ),
      ),
    );
  }
}
