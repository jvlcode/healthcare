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
import 'package:healthcare/features/chat/chat_screen.dart';
import 'package:healthcare/features/user/videocall_history_screen.dart';
import 'package:healthcare/features/videocall/videocall_screen.dart';
import 'package:healthcare/models/appointment_model.dart';
import 'package:healthcare/models/call_payload_model.dart';
import 'package:healthcare/services/appoinment_service.dart';
import 'package:healthcare/services/socket_service.dart';

class UserAppointmentsScreen extends StatefulWidget {
  const UserAppointmentsScreen({super.key});

  @override
  State<UserAppointmentsScreen> createState() => _UserAppointmentsScreenState();
}

class _UserAppointmentsScreenState extends State<UserAppointmentsScreen> {
  List<Appointment> bookings = [];
  bool _loading = true;
  String? _error;
  final socket = SocketService();

  @override
  void initState() {
    super.initState();
    _loadAppointments();
    _initSocketListeners();
  }

  Future<void> _initSocketListeners() async {
    socket.onCallEvent.listen((event) {
      final type = event["event"];
      final data = event["data"];

      if (type == SocketEvents.CALL_RINGING) {
        _handleIncomingCall(CallPayload.fromJson(data));
      }
    });
  }

  bool _isAppointmentExpired(Appointment booking) {
    return DateTime.now().isAfter(booking.slot.startDateTime);
  }

  // ---------------------------------------
  // Incoming Call Handler
  // ---------------------------------------
  void _handleIncomingCall(CallPayload payload) {
    navigateSlideLeft(
      context,
      page: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          _refreshAppointments();
        },
        child: VideoCallScreen(
          isDoctor: false,
          isIncoming: true,
          payload: payload,
        ),
      ),
    );
  }

  // ---------------------------------------
  // Load Appointments
  // ---------------------------------------
  Future<void> _loadAppointments() async {
    setState(() => _error = null);

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

  // Refresh
  Future<void> _refreshAppointments() async {
    await _loadAppointments();
    ToastUtil.success("Appointments updated!");
  }

  Color _statusColor(Appointment booking) {
    if (_isAppointmentExpired(booking)) {
      return Colors.grey;
    }
    switch (booking.status.toLowerCase()) {
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

  String statusText(Appointment booking) {
    if (_isAppointmentExpired(booking)) {
      return "EXPIRED";
    }
    switch (booking.status.toUpperCase()) {
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
        return booking.status;
    }
  }

  // ---------------------------------------
  // Action Buttons
  // ---------------------------------------
  Widget _renderActions(Appointment booking) {
    String status = booking.status.toUpperCase();
    final notAllowedStatuses = ['PENDING', 'COMPLETED', 'REJECTED', 'EXPIRED'];
    if (_isAppointmentExpired(booking)) {
      status = "EXPIRED";
    }

    if (!notAllowedStatuses.contains(status)) {
      return GFButton(
        onPressed: () => navigateSlideLeft(
          context,
          page: ChatScreen(
            toUserId: booking.doctor.user!.id,
            displayName: booking.doctor.name,
          ),
        ),
        text: "Chat",
        color: const Color(0xFFFF6B35),
        shape: GFButtonShape.pills,
      );
    }

    return const SizedBox.shrink();
  }

  // ---------------------------------------
  // MAIN UI
  // ---------------------------------------
  @override
  Widget build(BuildContext context) {
    return NetworkAwareScaffold(
      loading: _loading,
      error: _error,
      onRetry: _loadAppointments,
      child: Scaffold(
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
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                "Doctor Appointments",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              if (bookings.isEmpty)
                const Center(
                  child: Text(
                    "No appointments available",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ),
              const SizedBox(height: 12),
              ...bookings.map((booking) {
                return AppointmentCard(
                  avatar: CircleAvatar(
                    radius: 28,
                    child: SafeAvatar(
                      imageUrl: ImageUtils.resolve(booking.doctor.profileImage),
                      size: 120,
                    ),
                  ),
                  title: booking.doctor.application.personalInfo.fullName,
                  subtitle: booking.doctor.specialization,
                  status: statusText(booking),
                  statusColor: _statusColor(booking),
                  date: booking.slot.dateLabel,
                  timeRange:
                      "${booking.slot.startTimeLabel} - ${booking.slot.endTimeLabel}",
                  actionButtons: _renderActions(booking),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
