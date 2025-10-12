import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class UserBookingsScreen extends StatelessWidget {
  const UserBookingsScreen({super.key});

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
    return Scaffold(
      appBar: GFAppBar(
        title: const Text('My Appointments'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return GFCard(
            margin: const EdgeInsets.only(bottom: 12),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
                      ),
                      radius: 25,
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
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            booking['specialty'],
                            style: const TextStyle(color: Colors.grey),
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
                        color: _statusColor(booking['status']).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        booking['status'],
                        style: TextStyle(
                          color: _statusColor(booking['status']),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(booking['date']),
                    const SizedBox(width: 16),
                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(booking['time']),
                  ],
                ),
                const SizedBox(height: 8),
                GFButton(
                  onPressed: () {
                    GFToast.showToast(
                      "Details for ${booking['doctorName']}",
                      context,
                      toastPosition: GFToastPosition.BOTTOM,
                    );
                  },
                  text: "View Details",
                  type: GFButtonType.outline,
                  size: GFSize.SMALL,
                  color: Theme.of(context).primaryColor,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
