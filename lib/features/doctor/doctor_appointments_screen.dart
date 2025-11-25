import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';
import 'package:healthcare/core/helpers/network_helper.dart';
import 'package:healthcare/core/utils/image_util.dart';
import 'package:healthcare/core/utils/toast_util.dart';
import 'package:healthcare/core/widgets/appointment_card.dart';
import 'package:healthcare/core/widgets/confirmation_dialog.dart';
import 'package:healthcare/core/widgets/network_aware_scaffold.dart';
import 'package:healthcare/core/widgets/safe_avatar.dart';
import 'package:healthcare/features/chat/chat_screen.dart';
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
  bool isExpired(Appointment a) => DateTime.now().isAfter(a.slot.startDateTime);

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String displayStatus(String status) {
    switch (status.toUpperCase()) {
      case 'CALL_ACCEPTED':
        return "Call in progress";
      case 'CALL_REJECTED':
        return "Patient rejected the call";
      case 'CALL_MISSED':
        return "Patient missed the call";
      case 'CALL_CANCELLED':
        return "Doctor cancelled the call";
      case 'CALL_DISCONNECTED':
        return "Call disconnected";
      default:
        return status;
    }
  }

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
        ) ??
        false;
  }

  // ===============================
  // 📌 Action Buttons Builder
  // ===============================
  Widget actionButtons(Appointment a) {
    final status = a.status.toUpperCase();
    final expired = isExpired(a);

    // 🔹 If expired and not completed – show nothing
    if (expired && status != "COMPLETED") {
      return const SizedBox.shrink();
    }

    switch (status) {
      // -----------------------------------------
      // PENDING → Accept / Reject
      // -----------------------------------------
      case "PENDING":
        return Row(
          children: [
            Expanded(
              child: actionBtn(
                label: "Accept",
                color: Colors.green,
                onTap: () => updateStatus(a.id!, "ACCEPTED"),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: actionBtn(
                label: "Reject",
                color: Colors.red,
                onTap: () async {
                  if (await confirmAction(
                    "Reject Appointment",
                    "Are you sure?",
                  )) {
                    updateStatus(a.id!, "REJECTED");
                  }
                },
              ),
            ),
          ],
        );

      // ---------------------------------------------------
      // Accepted or Call states → Chat + Video Call
      // ---------------------------------------------------
      case "ACCEPTED":
      case "CALL_REJECTED":
      case "CALL_MISSED":
      case "CALL_DISCONNECTED":
      case "CALL_ENDED":
        return Row(
          children: [
            Expanded(
              child: actionBtn(
                label: "Chat",
                color: const Color(0xFFFF6B35),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      toId: a.patient.id,
                      displayName: a.patient.name,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: actionBtn(
                label: "Call",
                color: Colors.blue,
                icon: const Icon(Icons.videocam, color: Colors.white),
                onTap: () => startCall(a),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: actionBtn(
                label: "Complete",
                color: Colors.green,
                onTap: () async {
                  if (await confirmAction(
                    "Complete",
                    "Finish this appointment?",
                  )) {
                    updateStatus(a.id!, "COMPLETED");
                  }
                },
              ),
            ),
          ],
        );

      // -----------------------------------------
      // Ongoing call → Join / Complete
      // -----------------------------------------
      case "CALL_STARTED":
      case "CALL_ACCEPTED":
        return Row(
          children: [
            Expanded(
              child: actionBtn(
                label: "Complete",
                color: Colors.orange,
                onTap: () async {
                  if (await confirmAction(
                    "Complete",
                    "Finish this appointment?",
                  )) {
                    updateStatus(a.id!, "COMPLETED");
                  }
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: actionBtn(
                label: "Join Call",
                color: Colors.green,
                onTap: () => openCall(a),
              ),
            ),
          ],
        );
    }

    return const SizedBox.shrink();
  }

  // ===============================
  // 📌 Single Button Builder
  // ===============================
  GFButton actionBtn({
    required String label,
    required Color color,
    required VoidCallback onTap,
    Widget? icon,
  }) {
    return GFButton(
      onPressed: onTap,
      text: label,
      icon: icon,
      color: color,
      shape: GFButtonShape.pills,
    );
  }

  // ===============================
  // 📌 Call Logic
  // ===============================
  void startCall(Appointment a) {
    final payload = CallPayload(
      callerId: a.doctor.id,
      receiverId: a.patient.id,
      appointmentId: a.id!,
      doctorName: a.doctor.application.personalInfo.fullName,
      patientName: a.patient.name,
      roomId: "room_${a.id}",
      startTime: DateTime.now().toIso8601String(),
    );

    SocketService().emit(SocketEvents.CALL_STARTED, payload.toJson());

    openCall(a);
  }

  void openCall(Appointment a) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PopScope(
          onPopInvokedWithResult: (didPop, result) {
            _refreshAppointments();
          },
          child: VideoCallScreen(
            appointmentId: a.id!,
            doctorId: a.doctor.id,
            patientId: a.patient.id,
            isDoctor: true,
          ),
        ),
      ),
    );
  }

  // ===============================
  // 📌 Appointment List UI
  // ===============================
  Widget buildList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Patient Appointments",
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
        ...bookings.map((b) {
          final expired = isExpired(b);
          final status = b.status.toUpperCase();
          final display = expired && status != "COMPLETED"
              ? "EXPIRED"
              : displayStatus(status);

          return AppointmentCard(
            avatar: CircleAvatar(
              radius: 28,
              child: SafeAvatar(
                imageUrl: ImageUtils.resolve(b.patient.profileImage),
                size: 120,
              ),
            ),
            title: b.patient.name,
            subtitle: "Age: ${b.age} | Reason: ${b.reason}",
            status: display,
            statusColor: statusColor(display),
            date: b.slot.dateLabel,
            timeRange: "${b.slot.startTimeLabel} - ${b.slot.endTimeLabel}",
            actionButtons: actionButtons(b),
          );
        }),
      ],
    );
  }

  // ===============================
  // 📌 Build
  // ===============================
  @override
  Widget build(BuildContext context) {
    return NetworkAwareScaffold(
      loading: _loading,
      error: _error,
      onRetry: _refreshAppointments,
      child: RefreshIndicator(
        onRefresh: _refreshAppointments,
        child: buildList(),
      ),
    );
  }
}
