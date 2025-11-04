import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:healthcare/features/user/doctors/chat_screen.dart';
import 'package:healthcare/features/user/doctors/videocall_screen.dart';

class DoctorAppointmentsScreen extends StatelessWidget {
  const DoctorAppointmentsScreen({super.key});

  // --- Sample patient booking data
  final List<Map<String, dynamic>> patientBookings = const [
    {
      'patientName': 'Arun Kumar',
      'age': 34,
      'reason': 'Chest Pain',
      'date': '12 Oct 2025',
      'time': '10:00 AM',
      'status': 'Pending',
    },
    {
      'patientName': 'Lakshmi Devi',
      'age': 45,
      'reason': 'Tooth Checkup',
      'date': '15 Oct 2025',
      'time': '3:00 PM',
      'status': 'Confirmed',
    },
    {
      'patientName': 'Karthik Raj',
      'age': 29,
      'reason': 'Migraine Follow-up',
      'date': '20 Oct 2025',
      'time': '11:30 AM',
      'status': 'Cancelled',
    },
  ];

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F2),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: patientBookings.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Patient Appointments',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            );
          }

          final booking = patientBookings[index - 1];
          final statusColor = _statusColor(booking['status']);

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// --- Patient Info
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        backgroundImage: NetworkImage(
                          'https://cdn-icons-png.flaticon.com/512/847/847969.png',
                        ),
                        radius: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking['patientName'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "Age: ${booking['age']}",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        booking['status'],
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// --- Reason & Time
                Text(
                  "Reason: ${booking['reason']}",
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(booking['date'], style: const TextStyle(fontSize: 15)),
                    const SizedBox(width: 20),
                    const Icon(Icons.access_time, size: 18, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(booking['time'], style: const TextStyle(fontSize: 15)),
                  ],
                ),

                const SizedBox(height: 16),

                /// --- Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (booking['status'] == 'Pending') ...[
                      Expanded(
                        child: GFButton(
                          onPressed: () {
                            // TODO: handle accept action
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Appointment accepted!"),
                              ),
                            );
                          },
                          text: "Accept",
                          color: Colors.green,
                          size: GFSize.MEDIUM,
                          shape: GFButtonShape.pills,
                          icon: const Icon(
                            Icons.check_circle_outline,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GFButton(
                          onPressed: () {
                            // TODO: handle reject action
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Appointment rejected!"),
                              ),
                            );
                          },
                          text: "Reject",
                          color: Colors.red,
                          size: GFSize.MEDIUM,
                          shape: GFButtonShape.pills,
                          icon: const Icon(
                            Icons.cancel_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ] else if (booking['status'] == 'Confirmed') ...[
                      Expanded(
                        child: GFButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ChatScreen(),
                              ),
                            );
                          },
                          text: "Chat",
                          color: const Color(0xFFFF6B35),
                          size: GFSize.MEDIUM,
                          shape: GFButtonShape.pills,
                          icon: const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GFButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideoCallScreen(),
                              ),
                            );
                          },
                          text: "Start Call",
                          color: Colors.blue,
                          size: GFSize.MEDIUM,
                          shape: GFButtonShape.pills,
                          icon: const Icon(
                            Icons.videocam,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
