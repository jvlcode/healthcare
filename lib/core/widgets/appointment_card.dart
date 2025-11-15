import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class AppointmentCard extends StatelessWidget {
  final Widget avatar;
  final String title;
  final String subtitle;
  final String status;
  final Color statusColor;
  final String date;
  final String timeRange;
  final Widget actionButtons; // fully customizable

  const AppointmentCard({
    super.key,
    required this.avatar,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusColor,
    required this.date,
    required this.timeRange,
    required this.actionButtons,
  });

  Widget _buildSubtitle(String subtitle) {
    // format: "25|Fever and headache"  (age|reason)
    final parts = subtitle.split('|');
    final text1 = parts.isNotEmpty ? parts[0] : "";
    final text2 = parts.length > 1 ? parts[1] : "";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (text1.isNotEmpty)
          Text(
            "$text1",
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        if (text2.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            "$text2",
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
          /// --- Top Row (Avatar + name + specialition/patient)
          Row(
            children: [
              avatar,
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    if (subtitle.isNotEmpty) _buildSubtitle(subtitle),
                  ],
                ),
              ),

              /// --- Status Badge
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
                  status,
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

          /// --- Date & Time Row
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(date, style: const TextStyle(fontSize: 15)),

              const SizedBox(width: 20),
              const Icon(Icons.access_time, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(timeRange, style: const TextStyle(fontSize: 15)),
            ],
          ),

          const SizedBox(height: 16),

          /// --- Buttons passed from outside
          actionButtons,
        ],
      ),
    );
  }
}
