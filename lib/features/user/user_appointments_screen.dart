import 'dart:async';
import 'package:flutter/material.dart';
import 'package:healthcare/core/helpers/network_helper.dart';
import 'package:healthcare/core/utils/navigation_util.dart';
import 'package:healthcare/core/utils/toast_util.dart';
import 'package:healthcare/features/chat/chat_screen.dart';
import 'package:healthcare/features/shared/appointment_list.dart';
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

  void startChat(Appointment a) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChatScreen(toUserId: a.doctor.user!, displayName: a.doctor.name),
      ),
    );
  }

  // ---------------------------------------
  // MAIN UI
  // ---------------------------------------
  @override
  Widget build(BuildContext context) {
    return AppointmentList(
      bookings: bookings,
      isDoctor: false, // or false for UserAppointmentsScreen
      onCall: (appointment) async {},
      onRefresh: _refreshAppointments,
      onChat: (appointment) async {
        startChat(appointment);
      },
      onComplete: (appointment) async {},
      onAccept: (appointment) async {},
      onReject: (appointment) async {}, // your existing refresh function
    );
  }
}
