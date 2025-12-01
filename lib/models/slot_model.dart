import 'package:intl/intl.dart';

class Slot {
  final String id;
  final DateTime startAt;
  final DateTime endAt;
  final String dateLabel;
  final String startTimeLabel;
  final String endTimeLabel;
  final bool available;

  Slot({
    required this.id,
    required this.startAt,
    required this.endAt,
    required this.dateLabel,
    required this.startTimeLabel,
    required this.endTimeLabel,
    required this.available,
  });

  /// Safe factory constructor
  factory Slot.fromJson(Map<String, dynamic> json) {
    try {
      final startRaw = json["startAt"]?.toString();
      final endRaw = json["endAt"]?.toString();

      final start = startRaw != null
          ? (DateTime.tryParse(startRaw)?.toLocal() ?? DateTime.now())
          : DateTime.now();

      final end = endRaw != null
          ? (DateTime.tryParse(endRaw)?.toLocal() ??
                start.add(const Duration(minutes: 15)))
          : start.add(const Duration(minutes: 15));

      return Slot(
        id: json["_id"]?.toString() ?? json["id"]?.toString() ?? "",
        startAt: start,
        endAt: end,
        dateLabel: DateFormat('d MMM').format(start),
        startTimeLabel: DateFormat.jm().format(start),
        endTimeLabel: DateFormat.jm().format(end),
        available: json["available"] ?? false,
      );
    } catch (e) {
      print("❌ Slot parsing failed: $e — Returning Slot.empty()");
      return Slot.empty();
    }
  }

  /// SAFE fallback slot (prevents crashes in appointment parsing)
  static Slot empty() {
    final now = DateTime.now();
    return Slot(
      id: "",
      startAt: now,
      endAt: now.add(const Duration(minutes: 15)),
      dateLabel: DateFormat('d MMM').format(now),
      startTimeLabel: DateFormat.jm().format(now),
      endTimeLabel: DateFormat.jm().format(
        now.add(const Duration(minutes: 15)),
      ),
      available: false,
    );
  }

  Slot copyWith({
    String? id,
    DateTime? startAt,
    DateTime? endAt,
    bool? available,
  }) {
    final s = (startAt ?? this.startAt).toLocal();
    final e = (endAt ?? this.endAt).toLocal();

    return Slot(
      id: id ?? this.id,
      startAt: s,
      endAt: e,
      dateLabel: DateFormat('d MMM').format(s),
      startTimeLabel: DateFormat.jm().format(s),
      endTimeLabel: DateFormat.jm().format(e),
      available: available ?? this.available,
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "startAt": startAt.toIso8601String(),
    "endAt": endAt.toIso8601String(),
    "available": available,
  };
}
