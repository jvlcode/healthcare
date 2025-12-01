import 'package:intl/intl.dart';

class VideoCall {
  final String id;
  final String doctorName;
  final String specialty;
  final DateTime startedAt;
  final DateTime endedAt;
  String? videoUrl;

  VideoCall({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.startedAt,
    required this.endedAt,
    this.videoUrl,
  });

  // UI Helpers
  String get date => DateFormat('MMM d, yyyy').format(startedAt.toLocal());
  String get time => DateFormat('h:mm a').format(startedAt.toLocal());

  // Duration between start and end
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

  /// Safe JSON parser
  factory VideoCall.fromJson(Map<String, dynamic> json) {
    try {
      final startRaw = json['startedAt']?.toString();
      final endRaw = json['endedAt']?.toString();

      final startedAt = startRaw != null
          ? DateTime.tryParse(startRaw)?.toLocal() ?? DateTime.now()
          : DateTime.now();

      final endedAt = endRaw != null
          ? DateTime.tryParse(endRaw)?.toLocal() ??
                startedAt.add(const Duration(minutes: 30))
          : startedAt.add(const Duration(minutes: 30));

      return VideoCall(
        id: json['_id']?.toString() ?? "temp_id",
        doctorName:
            json["doctor"]?["application"]?["personalInfo"]?["fullName"] ?? "",
        specialty: json["doctor"]?["specialization"] ?? "",
        startedAt: startedAt,
        endedAt: endedAt,
        videoUrl: json["videoUrl"],
      );
    } catch (e, stack) {
      print('❌ Failed to parse VideoCall: $e');
      print('Stack: $stack');
      print('Raw JSON: $json');
      rethrow;
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    "_id": id,
    "doctorName": doctorName,
    "specialty": specialty,
    "startedAt": startedAt.toIso8601String(),
    "endedAt": endedAt.toIso8601String(),
    "videoUrl": videoUrl,
  };

  /// Empty object
  factory VideoCall.empty() {
    final now = DateTime.now();
    return VideoCall(
      id: "",
      doctorName: "",
      specialty: "",
      startedAt: now,
      endedAt: now.add(const Duration(minutes: 30)),
      videoUrl: null,
    );
  }
}
