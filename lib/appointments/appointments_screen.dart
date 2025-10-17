import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:healthcare/appointments/videocall_history_screen.dart';
import 'package:healthcare/doctors/chat_screen.dart';
import 'package:healthcare/doctors/videocall_screen.dart';
import 'package:healthcare/core/app_header.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  // Sample booking data
  final List<Map<String, dynamic>> bookings = const [
    {
      'doctorName': 'Dr. Priya Sharma',
      'specialty': 'Cardiologist',
      'date': '12 Oct 2025',
      'time': '10:00 AM',
      'status': 'Confirmed',
    },
    {
      'doctorName': 'Dr. Rajesh Nair',
      'specialty': 'Dentist',
      'date': '15 Oct 2025',
      'time': '3:00 PM',
      'status': 'Pending',
    },
    {
      'doctorName': 'Dr. Kavitha Rao',
      'specialty': 'Neurologist',
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
        itemCount: bookings.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'Appointments',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
            );
          }
          final booking = bookings[index - 1];
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
                /// --- Doctor Info Row
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
                          'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
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
                            booking['doctorName'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            booking['specialty'],
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
                const SizedBox(height: 14),

                /// --- Appointment Date and Time
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

                /// --- Buttons Row
                /// --- Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GFButton(
                        onPressed: booking['status'] == 'Cancelled'
                            ? null
                            : () {
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
                        onPressed: booking['status'] == 'Cancelled'
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VideoCallScreen(),
                                  ),
                                );
                              },
                        text: "Video Call",
                        color: Colors.green,
                        size: GFSize.MEDIUM,
                        shape: GFButtonShape.pills,
                        icon: const Icon(
                          Icons.videocam_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VideoCallHistoryScreen()),
          );
        },
        backgroundColor: const Color(0xFF01312F),
        icon: const Icon(Icons.history, color: Colors.white),
        label: const Text(
          "Video Call History",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
