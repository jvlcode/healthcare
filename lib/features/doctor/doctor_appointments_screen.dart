import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';
import 'package:healthcare/app/session/reachability_controller.dart';
import 'package:healthcare/core/helpers/network_helper.dart';
import 'package:healthcare/core/utils/image_util.dart';
import 'package:healthcare/core/utils/toast_util.dart';
import 'package:healthcare/core/widgets/appointment_card.dart';
import 'package:healthcare/core/widgets/confirmation_dialog.dart';
import 'package:healthcare/core/widgets/network_aware_scaffold.dart';
import 'package:healthcare/core/widgets/safe_avatar.dart';
import 'package:healthcare/features/user/doctors/chat_screen.dart';
import 'package:healthcare/features/videocall/videocall_screen.dart';
import 'package:healthcare/models/appointment_model.dart';
import 'package:healthcare/services/appoinment_service.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});
  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  List<Appointment> bookings = [];
  bool _loading = true;
  String? _error;

  final AppointmentService service = AppointmentService();

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    await NetworkHelper().safeCall(
      context,
      () => service.getUserAppointments(),
      onSuccess: (res) {
        setState(() {
          final data = res['data'] as List<dynamic>;
          bookings = data.map((e) => Appointment.fromJson(e)).toList();
        });
      },
      onApiError: (res) {
        final map = res as Map<String, dynamic>?;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(map?['message'] ?? 'Load failed')),
        );
      },
      onException: (e) => _error = e.toString(),
    );
    setState(() {
      _loading = false;
    });
  }

  Future<void> _refreshAppointments() async {
    await _loadAppointments();
    ToastUtil.success("Appointments updated!", gravity: ToastGravity.TOP);
  }

  Future<void> handleStatusUpdate(String id, String status) async {
    await NetworkHelper().safeCall(
      context,
      () => service.updateAppointmentStatus(appointmentId: id, status: status),
      onSuccess: (_) {
        setState(() {
          final index = bookings.indexWhere((b) => b.id == id);
          if (index != -1) bookings[index].status = status;
        });
        if (status == 'STARTED') {
          ToastUtil.success("Call started!");
        }
        if (status == 'ACCEPTED') {
          ToastUtil.success("You have accepted this appointment!");
        }
        if (status == 'COMPLETED') {
          ToastUtil.success("This appointment has been completed!");
        }
      },
      onApiError: (res) {
        final map = res as Map<String, dynamic>?;
        ToastUtil.error(map?['message'] ?? 'Update failed');
      },
      onException: (e) {
        ToastUtil.error(e.toString());
      },
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  bool _isAppointmentExpired(Appointment booking) =>
      DateTime.now().isAfter(booking.slot.startDateTime);

  Widget _renderActions(Appointment booking) {
    final status = booking.status.toUpperCase();
    final isExpired = _isAppointmentExpired(booking);

    if (status == "ACCEPTED" && isExpired) return const SizedBox.shrink();

    if (status == "PENDING") {
      return Row(
        children: [
          Expanded(
            child: GFButton(
              onPressed: () => handleStatusUpdate(booking.id, "ACCEPTED"),
              text: "Accept",
              color: Colors.green,
              shape: GFButtonShape.pills,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GFButton(
              onPressed: () async {
                final confirmed = await showConfirmationDialog(
                  context: context,
                  title: "Reject Appointment",
                  message: "Are you sure you want to reject this appointment?",
                  confirmText: "Yes",
                  cancelText: "No",
                  confirmColor: Colors.red,
                );

                if (confirmed) {
                  handleStatusUpdate(booking.id, "REJECTED");
                }
              },
              text: "Reject",
              color: Colors.red,
              shape: GFButtonShape.pills,
            ),
          ),
        ],
      );
    }

    if (status == "ACCEPTED") {
      return Row(
        children: [
          Expanded(
            child: GFButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatScreen()),
              ),
              text: "Chat",
              color: const Color(0xFFFF6B35),
              shape: GFButtonShape.pills,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GFButton(
              onPressed: () async {
                await handleStatusUpdate(booking.id, "STARTED");
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VideoCallScreen(
                      appointmentId: booking.id,
                      doctorId: booking.doctor.id,
                      patientId: booking.patient.id,
                      isDoctor: true,
                    ),
                  ),
                );
              },
              text: "Start Call",
              color: Colors.blue,
              shape: GFButtonShape.pills,
            ),
          ),
        ],
      );
    }

    if (status == "STARTED") {
      return Row(
        children: [
          Expanded(
            child: GFButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoCallScreen(
                    appointmentId: booking.id,
                    doctorId: booking.doctor.id,
                    patientId: booking.patient.id,
                    isDoctor: true,
                  ),
                ),
              ),
              text: "Join Call",
              color: Colors.green,
              shape: GFButtonShape.pills,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GFButton(
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Complete Appointment"),
                    content: const Text(
                      "Are you sure you want to complete the appointment?",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("No"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Yes"),
                      ),
                    ],
                  ),
                );
                if (ok == true) handleStatusUpdate(booking.id, "COMPLETED");
              },
              text: "Complete",
              color: Colors.orange,
              shape: GFButtonShape.pills,
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildAppointmentList() {
    if (bookings.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: const Center(
              child: Text(
                "No appointments available",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Patient Appointments",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...bookings.map((b) {
          final isExpired = _isAppointmentExpired(b);
          final status = b.status.toUpperCase();
          final displayStatus = (isExpired && status != "COMPLETED")
              ? "EXPIRED"
              : status;

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
            status: displayStatus,
            statusColor: displayStatus == "EXPIRED"
                ? Colors.grey
                : _statusColor(displayStatus),
            date: b.slot.dateLabel,
            timeRange: "${b.slot.startTimeLabel} - ${b.slot.endTimeLabel}",
            actionButtons: _renderActions(b),
          );
        }).toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return NetworkAwareScaffold(
      error: _error,
      loading: _loading,
      onRetry: _refreshAppointments,
      child: RefreshIndicator(
        onRefresh: _refreshAppointments,
        child: _buildAppointmentList(),
      ),
    );
  }
}
