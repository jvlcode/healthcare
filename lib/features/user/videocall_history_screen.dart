import 'package:flutter/material.dart';
import 'package:healthcare/features/user/videocall_history/videoplayer_screen.dart';

class VideoCallHistoryScreen extends StatelessWidget {
  const VideoCallHistoryScreen({super.key});

  final List<Map<String, String>> callHistory = const [
    {
      'doctorName': 'Dr. Priya Sha',
      'specialty': 'Cardiologist',
      'date': '10 Oct 2025',
      'time': '10:00 AM',
      'duration': '25 mins',
      'status': 'Completed',
      'videoUrl':
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
    },
    {
      'doctorName': 'Dr. Rajesh Nair',
      'specialty': 'Dentist',
      'date': '05 Oct 2025',
      'time': '3:30 PM',
      'duration': '15 mins',
      'status': 'Completed',
      'videoUrl':
          'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    },
    {
      'doctorName': 'Dr. Kavitha Rao',
      'specialty': 'Neurologist',
      'date': '28 Sep 2025',
      'time': '11:00 AM',
      'duration': 'Missed',
      'status': 'Missed',
      'videoUrl':
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
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

  Future<void> backupVideo(String doctorName) async {
    // TODO: Implement actual download logic here
    debugPrint("Backing up video for: $doctorName");
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
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_download, color: Colors.white),
            onPressed: () {
              // Backup all
              for (var call in callHistory) {
                backupVideo(call['doctorName']!);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Backup started for all available videos"),
                ),
              );
            },
          ),
        ],
      ),

      // ---------------------- 7 DAYS WARNING BANNER ----------------------
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.yellow.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Note: Our server stores your video temporarily for 7 days. "
                    "Please backup important videos.",
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          // ---------------------- HISTORY LIST ----------------------
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: callHistory.length,
              itemBuilder: (context, index) {
                final call = callHistory[index];
                final color = _statusColor(call['status']!);

                // use StatefulBuilder to hold per-row state
                return StatefulBuilder(
                  builder: (context, setRowState) {
                    bool isBackingUp = false;

                    Future<void> startBackup() async {
                      setRowState(() {
                        isBackingUp = true;
                      });

                      await Future.delayed(
                        const Duration(seconds: 2),
                      ); // mock backup

                      setRowState(() {
                        isBackingUp = false;
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "${call['doctorName']} backup completed",
                          ),
                        ),
                      );
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VideoPlayerScreen(
                              videoUrl: call['videoUrl']!,
                              doctorName: call['doctorName']!,
                            ),
                          ),
                        );
                      },
                      child: Container(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const CircleAvatar(
                              backgroundImage: NetworkImage(
                                'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
                              ),
                              radius: 30,
                            ),

                            const SizedBox(width: 12),

                            // -------- Prevent overflow by using Flexible --------
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    call['doctorName']!,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),

                                  Text(
                                    call['specialty']!,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
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
                                      Flexible(
                                        child: Text(
                                          call['date']!,
                                          style: const TextStyle(fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          call['time']!,
                                          style: const TextStyle(fontSize: 13),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    "Duration: ${call['duration']}",
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // -------- RIGHT SIDE ICONS (Cloud + Play) --------
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                isBackingUp
                                    ? const SizedBox(
                                        width: 26,
                                        height: 26,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                        ),
                                      )
                                    : IconButton(
                                        icon: const Icon(Icons.download),
                                        color: Colors.blue,
                                        onPressed: () => startBackup(),
                                      ),

                                const SizedBox(width: 4),

                                Icon(
                                  Icons.play_circle_fill,
                                  color: color,
                                  size: 28,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
