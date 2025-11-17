import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';
import 'package:healthcare/app/session/reachability_controller.dart';
import 'package:healthcare/core/widgets/appointment_card.dart';
import 'package:healthcare/core/widgets/retry_loader.dart';
import 'package:healthcare/core/widgets/server_gaurd.dart';
import 'package:healthcare/features/user/doctors/chat_screen.dart';
import 'package:healthcare/features/videocall/videocall_screen.dart';
import 'package:healthcare/models/appointment_model.dart';
import 'package:healthcare/services/appoinment_service.dart';
import 'package:provider/provider.dart';

class DoctorAppointmentsScreen extends StatefulWidget {
  const DoctorAppointmentsScreen({super.key});
  @override
  State<DoctorAppointmentsScreen> createState() =>
      _DoctorAppointmentsScreenState();
}

class _DoctorAppointmentsScreenState extends State<DoctorAppointmentsScreen> {
  List<Appointment> bookings = [];
  bool _loading = true;
  String? error;
  bool _appointmentsLoaded = false;

  final AppointmentService service = AppointmentService();
  late ReachabilityController reachability;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      reachability = context.read<ReachabilityController>();

      // If server is reachable, load appointments
      if (reachability.isServerReachable) {
        _appointmentsLoaded = true;
        _loadAppointments();
      } else {
        setState(() => _loading = false);
      }

      // Listen for server coming back online
      reachability.addListener(_handleReachabilityChange);
    });
  }

  void _handleReachabilityChange() {
    if (reachability.isServerReachable && !_appointmentsLoaded) {
      _appointmentsLoaded = true;
      _loadAppointments();
    }
  }

  @override
  void dispose() {
    reachability.removeListener(_handleReachabilityChange);
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _loading = true;
      error = null;
    });

    try {
      final res = await service.getUserAppointments();
      setState(() {
        final data =
            res['data'] as List<dynamic>; // cast to List<dynamic> first
        bookings = data.map((e) => Appointment.fromJson(e)).toList();
        // bookings = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> handleStatusUpdate(String id, String status) async {
    if (!reachability.isServerReachable) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Server unreachable")));
      return;
    }

    final ok = await service.updateAppointmentStatus(
      appointmentId: id,
      status: status,
    );

    if (ok) {
      _loadAppointments();
    }
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

  // -----------------------------------------
  // WRAP EVERYTHING WITH SERVER GUARD HERE
  // -----------------------------------------
  @override
  Widget build(BuildContext context) {
    reachability = context.watch<ReachabilityController>();

    return ServerGuard(onRetry: _loadAppointments, child: _buildMainUI());
  }

  // -----------------------------------------
  // MAIN UI (ServerGuard shows offline UI)
  // -----------------------------------------
  Widget _buildMainUI() {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null) {
      return RetryLoader(
        isLoading: false,
        hasError: true,
        errorMessage: error ?? "Something went wrong",
        onRetry: _loadAppointments,
        child: const SizedBox(),
      );
    }

    if (bookings.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6FAF9),
        body: Center(
          child: Text(
            "No appointments available",
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAF9),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Patient Appointments",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ...bookings.map((booking) {
            return AppointmentCard(
              avatar: const CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(
                  'https://cdn-icons-png.flaticon.com/512/847/847969.png',
                ),
              ),
              title: booking.patient.name,
              subtitle: "Age: ${booking.age} | Reason: ${booking.reason}",
              status: booking.status,
              statusColor: _statusColor(booking.status),
              date: booking.slot.dateLabel,
              timeRange:
                  "${booking.slot.startTimeLabel} - ${booking.slot.endTimeLabel}",
              actionButtons: _renderActions(booking),
            );
          }),
        ],
      ),
    );
  }

  // -----------------------------------------
  // ACTION BUTTONS CLEANED
  // -----------------------------------------
  Widget _renderActions(Appointment booking) {
    final status = booking.status.toLowerCase();

    if (status == 'pending') {
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
              onPressed: () => handleStatusUpdate(booking.id, "CANCELLED"),
              text: "Reject",
              color: Colors.red,
              shape: GFButtonShape.pills,
            ),
          ),
        ],
      );
    }

    if (status == 'accepted') {
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
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoCallScreen(
                    appointmentId: booking.id,
                    doctorId: booking.doctor.id,
                    patientId: booking.patient.id,
                  ),
                ),
              ),
              text: "Start Call",
              color: Colors.blue,
              shape: GFButtonShape.pills,
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
