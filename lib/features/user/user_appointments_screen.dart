import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/shape/gf_button_shape.dart';
import 'package:healthcare/core/helpers/network_helper.dart';
import 'package:healthcare/core/utils/image_util.dart';
import 'package:healthcare/core/utils/navigation_util.dart';
import 'package:healthcare/core/utils/toast_util.dart';
import 'package:healthcare/core/widgets/appointment_card.dart';
import 'package:healthcare/core/widgets/network_aware_scaffold.dart';
import 'package:healthcare/core/widgets/safe_avatar.dart';
import 'package:healthcare/features/user/doctors/chat_screen.dart';
import 'package:healthcare/features/user/videocall_history_screen.dart';
import 'package:healthcare/features/videocall/videocall_screen.dart';
import 'package:healthcare/models/appointment_model.dart';
import 'package:healthcare/services/appoinment_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadAppointments();

    // Auto refresh every 10 seconds
    _autoRefreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _loadAppointments(),
    );
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    super.dispose();
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
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
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
                      status: booking.status,
                      statusColor: statusColor,
                      date: booking.slot.dateLabel,
                      timeRange:
                          "${booking.slot.startTimeLabel} - ${booking.slot.endTimeLabel}",
                      actionButtons: booking.status.toLowerCase() == 'started'
                          ? Row(
                              children: [
                                Expanded(
                                  child: GFButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ChatScreen(),
                                      ),
                                    ),
                                    text: "Chat",
                                    color: const Color(0xFFFF6B35),
                                    shape: GFButtonShape.pills,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: GFButton(
                                    onPressed: () => navigateSlideLeft(
                                      context,
                                      page: VideoCallScreen(
                                        appointmentId: booking.id,
                                        doctorId: booking.doctor.id,
                                        patientId: booking.patient.id,
                                        isDoctor: false,
                                      ),
                                    ),
                                    text: "Join Call",
                                    color: Colors.green,
                                    shape: GFButtonShape.pills,
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    );
                  }),
                ],
              ),
      ),
    );
  }
}
