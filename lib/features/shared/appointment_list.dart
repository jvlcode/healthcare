import 'package:flutter/material.dart';
import 'package:healthcare/core/utils/image_util.dart';
import 'package:healthcare/core/widgets/appointment_card.dart';
import 'package:healthcare/core/widgets/safe_avatar.dart';
import 'package:healthcare/features/doctor/doctor_actions_button.dart';
import 'package:healthcare/features/shared/appointment_manager.dart';
import 'package:healthcare/features/user/user_action_buttons.dart';
import 'package:healthcare/models/appointment_model.dart';

class AppointmentList extends StatelessWidget {
  final List<Appointment> bookings;
  final bool isDoctor;
  final Future<void> Function(Appointment) onCall;
  final Future<void> Function(Appointment) onChat;
  final Future<void> Function(Appointment) onComplete;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Appointment) onAccept;
  final Future<void> Function(Appointment) onReject;

  const AppointmentList({
    super.key,
    required this.bookings,
    required this.isDoctor,
    required this.onCall,
    required this.onChat,
    required this.onComplete,
    required this.onRefresh,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            isDoctor ? "Patient Appointments" : "Doctor Appointments",
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
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
            final expired = AppointmentManager.isExpired(b);
            final status = AppointmentManager.displayStatus(
              b.status,
              expired: expired,
            );

            return AppointmentCard(
              avatar: CircleAvatar(
                radius: 28,
                child: SafeAvatar(
                  imageUrl: ImageUtils.resolve(
                    isDoctor ? b.patient.profileImage : b.doctor.profileImage,
                  ),
                  size: 120,
                ),
              ),
              title: isDoctor
                  ? b.patient.name
                  : b.doctor.application.personalInfo.fullName,
              subtitle: isDoctor
                  ? "Age: ${b.age} | Reason: ${b.reason}"
                  : b.doctor.specialization,
              status: status,
              statusColor: AppointmentManager.statusColor(status),
              date: b.slot.dateLabel,
              timeRange: "${b.slot.startTimeLabel} - ${b.slot.endTimeLabel}",
              actionButtons: Visibility(
                visible: !expired,
                child: isDoctor
                    ? DoctorActionButtons(
                        appointment: b,
                        onCall: onCall,
                        onChat: onChat,
                        onComplete: onComplete,
                        onAccept: onAccept,
                        onReject: onReject,
                      )
                    : UserActionButtons(appointment: b, onCall: onCall),
              ),
            );
          }),
        ],
      ),
    );
  }
}
