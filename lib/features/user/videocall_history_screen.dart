import 'package:flutter/material.dart';

class VideoCallHistoryScreen extends StatelessWidget {
  const VideoCallHistoryScreen({super.key});

  // Sample call history data
  final List<Map<String, String>> callHistory = const [
    {
      'doctorName': 'Dr. Priya Sha',
      'specialty': 'Cardiologist',
      'date': '10 Oct 2025',
      'time': '10:00 AM',
      'duration': '25 mins',
      'status': 'Completed',
    },
    {
      'doctorName': 'Dr. Rajesh Nair',
      'specialty': 'Dentist',
      'date': '05 Oct 2025',
      'time': '3:30 PM',
      'duration': '15 mins',
      'status': 'Completed',
    },
    {
      'doctorName': 'Dr. Kavitha Rao',
      'specialty': 'Neurologist',
      'date': '28 Sep 2025',
      'time': '11:00 AM',
      'duration': 'Missed',
      'status': 'Missed',
    },
  ];

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'missed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF01312F),
        title: const Text(
          "Video Call History",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: callHistory.length,
        itemBuilder: (context, index) {
          final call = callHistory[index];
          final color = _statusColor(call['status']!);

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
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
                  ),
                  radius: 30,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        call['doctorName']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        call['specialty']!,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            call['date']!,
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            call['time']!,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Duration: ${call['duration']}",
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
