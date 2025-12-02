import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:healthcare/core/helpers/network_helper.dart';
import 'package:healthcare/core/utils/toast_util.dart';
import 'package:healthcare/core/widgets/confirmation_dialog.dart';
import 'package:healthcare/features/chat/chat_screen.dart';
import 'package:healthcare/features/shared/appointment_list.dart';
import 'package:healthcare/features/videocall/videocall_screen.dart';
import 'package:healthcare/models/appointment_model.dart';
import 'package:healthcare/models/call_payload_model.dart';
import 'package:healthcare/services/appoinment_service.dart';
import 'package:healthcare/services/socket_service.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});

  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  final AppointmentService appointmentService = AppointmentService();

  List<Appointment> bookings = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  // ===============================
  // 📌 Data Fetching
  // ===============================
  Future<void> _loadAppointments() async {
    setState(() => _loading = true);

    await NetworkHelper().safeCall(
      context,
      () => appointmentService.getUserAppointments(),
      onSuccess: (res) {
        final data = res['data'] as List;
        bookings = data.map((e) => Appointment.fromJson(e)).toList();
      },
      onApiError: (res) {
        ToastUtil.error((res as Map?)?['message'] ?? "Load failed");
      },
      onException: (e) => _error = e.toString(),
    );

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _refreshAppointments() async {
    await _loadAppointments();
    ToastUtil.success("Appointments updated!", gravity: ToastGravity.TOP);
  }

  // ===============================
  // 📌 Helpers
  // ===============================
  bool isExpired(Appointment a) => DateTime.now().isAfter(a.slot.startAt);

  Future<void> updateStatus(String id, String status) async {
    await NetworkHelper().safeCall(
      context,
      () => appointmentService.updateAppointmentStatus(
        appointmentId: id,
        status: status,
      ),
      onSuccess: (_) {
        final index = bookings.indexWhere((b) => b.id == id);
        if (index != -1) {
          setState(() => bookings[index].status = status);
        }

        switch (status) {
          case 'CALL_STARTED':
            ToastUtil.info("Call started!");
            break;
          case 'ACCEPTED':
            ToastUtil.success("Appointment accepted!");
            break;
          case 'COMPLETED':
            ToastUtil.success("Appointment completed!");
            break;
        }
      },
      onApiError: (res) {
        ToastUtil.error((res as Map?)?['message'] ?? 'Update failed');
      },
      onException: (e) => _error = e.toString(),
    );
  }

  Future<bool> confirmAction(String title, String message) async {
    return await showConfirmationDialog(
      context: context,
      title: title,
      message: message,
      confirmText: "Yes",
      cancelText: "No",
      confirmColor: Colors.red,
    );
  }

  // ===============================
  // 📌 Call Logic
  // ===============================

  void startCall(Appointment a) {
    final payload = CallPayload(
      fromUserId: a.doctor.user!,
      toUserId: a.patient.id,
      doctorId: a.doctor.id,
      appointmentId: a.id!,
      doctorName: a.doctor.application.personalInfo.fullName,
      patientName: a.patient.name,
      roomId: "room_${a.id}",
      startTime: DateTime.now().toIso8601String(),
      patientId: a.patient.id,
    );

    SocketService().emit(SocketEvents.CALL_STARTED, payload.toJson());
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              _refreshAppointments();
            }
          },
          child: VideoCallScreen(isDoctor: true, payload: payload),
        ),
      ),
    );
  }

  void startChat(Appointment a) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChatScreen(toUserId: a.patient.id, displayName: a.patient.name),
      ),
    );
  }

  // ===============================
  // 📌 Build
  // ===============================
  @override
  Widget build(BuildContext context) {
    return AppointmentList(
      bookings: bookings,
      isDoctor: true, // or false for UserAppointmentsScreen
      onCall: (appointment) async {
        // Doctor: start call logic
        // User: maybe navigate to chat or call screen
        startCall(appointment);
      },
      onRefresh: _refreshAppointments,
      onChat: (appointment) async {
        // Doctor: start call logic
        // User: maybe navigate to chat or call screen
        startChat(appointment);
      },
      onComplete: (appointment) async {
        if (await confirmAction("Complete", "Finish this appointment?")) {
          updateStatus(appointment.id, "COMPLETED");
        }
      },
      onAccept: (appointment) async {
        if (await confirmAction(
          "Accept",
          "Are you sure to accept this Appointment?",
        )) {
          updateStatus(appointment.id, "ACCEPTED");
        }
      },
      onReject: (appointment) async {
        if (await confirmAction(
          "Complete",
          "Are you sure to reject this Appointment?",
        )) {
          updateStatus(appointment.id, "REJECTED");
        }
      },
    );
  }
}
