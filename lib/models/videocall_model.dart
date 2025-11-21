import 'package:intl/intl.dart';

class VideoCall {
  final String id;
  final String doctorName;
  final String specialty;
  final DateTime startedAt;
  final DateTime endedAt;
  String? videoUrl;

  VideoCall({
    required this.doctorName,
    required this.specialty,
    required this.startedAt,
    required this.endedAt,
    this.videoUrl,
    required this.id,
  });

  // ✅ Helpers for UI
  String get date => DateFormat('MMM d, yyyy').format(startedAt.toLocal());
  String get time => DateFormat('h:mm a').format(startedAt.toLocal());

  /// ✅ Duration between start and end
  String get duration {
    final diff = endedAt.difference(startedAt);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    if (hours > 0) {
      return "${hours}h ${minutes}m";
    } else if (minutes > 0) {
      return "${minutes}m ${seconds}s";
    } else {
      return "${seconds}s";
    }
  }

  factory VideoCall.fromJson(Map<String, dynamic> json) {
    try {
      return VideoCall(
        id: json['_id'] ?? "temp_id",

        doctorName:
            json["doctor"]?["application"]?["personalInfo"]?["fullName"] ?? "",
        specialty: json["doctor"]?["specialization"] ?? "",
        startedAt: DateTime.parse(json['startedAt']),
        endedAt: DateTime.parse(json['endedAt']),
        videoUrl: json["videoUrl"],
      );
    } catch (e, stack) {
      print('❌ Failed to parse VideoCall: $e');
      print('Stack: $stack');
      print('Raw JSON: $json');
      rethrow;
    }
  }
}
