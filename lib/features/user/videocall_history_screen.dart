import 'package:flutter/material.dart';
import 'package:healthcare/core/helpers/network_helper.dart';
import 'package:healthcare/core/utils/toast_util.dart';
import 'package:healthcare/features/user/videocall_history/videoplayer_screen.dart';
import 'package:healthcare/models/videocall_model.dart';
import 'package:healthcare/services/videocall_service.dart';

class VideoCallHistoryScreen extends StatefulWidget {
  const VideoCallHistoryScreen({super.key});

  @override
  State<VideoCallHistoryScreen> createState() => _VideoCallHistoryScreenState();
}

class _VideoCallHistoryScreenState extends State<VideoCallHistoryScreen> {
  List<VideoCall> historyList = [];
  bool _loading = true;
  String? _error;

  final service = VideoCallService();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await NetworkHelper().safeCall(
        context,
        () => service.getVideoCallHistory(),
        onSuccess: (res) {
          final data = res['data'] as List;
          historyList = data.map((e) => VideoCall.fromJson(e)).toList();
          ;
        },
        onApiError: (_) => _error = "Failed to load video call history",
        onException: (e) => _error = e.toString(),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refreshHistory() async {
    await _loadHistory();
    ToastUtil.success("History updated");
  }

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
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(
                _error!,
                style: const TextStyle(fontSize: 18, color: Colors.red),
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshHistory,
              child: historyList.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: const Center(
                            child: Text(
                              "No history found",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: historyList.length,
                      itemBuilder: (context, index) {
                        final call = historyList[index];
                        final color = _statusColor("completed");

                        return GestureDetector(
                          onTap: () {
                            if (call.videoUrl == null) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VideoPlayerScreen(
                                  videoUrl: call.videoUrl ?? "",
                                  doctorName: call.doctorName,
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
                              children: [
                                // const CircleAvatar(
                                //   backgroundImage: NetworkImage(
                                //     'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
                                //   ),
                                //   radius: 30,
                                // ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        call.doctorName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        call.specialty,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "${call.date} | ${call.time}",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      Text(
                                        "Duration: ${call.duration}",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.play_circle_fill,
                                  color: color,
                                  size: 28,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
