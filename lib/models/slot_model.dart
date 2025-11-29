import 'package:intl/intl.dart';

class Slot {
  String id;
  DateTime startAt;
  DateTime endAt;
  String dateLabel;
  String startTimeLabel;
  String endTimeLabel;
  bool available;

  Slot({
    required this.id,
    required this.startAt,
    required this.endAt,
    required this.dateLabel,
    required this.startTimeLabel,
    required this.endTimeLabel,
    required this.available,
  });

  factory Slot.fromJson(Map<String, dynamic> json) {
    final start = DateTime.parse(json["startAt"]);
    final end = DateTime.parse(json["endAt"]);
    return Slot(
      id: json["_id"] ?? json["id"],
      startAt: start,
      endAt: end,
      dateLabel: DateFormat('d MMM').format(start),
      startTimeLabel: DateFormat.jm().format(start),
      endTimeLabel: DateFormat.jm().format(end),
      available: json["available"] ?? false,
    );
  }

  Slot copyWith({String? id, DateTime? startAt, DateTime? endAt}) {
    return Slot(
      id: id ?? this.id,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      dateLabel: DateFormat('d MMM').format(startAt ?? this.startAt),
      startTimeLabel: DateFormat.jm().format(startAt ?? this.startAt),
      endTimeLabel: DateFormat.jm().format(endAt ?? this.endAt),
      available: available,
    );
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "startAt": startAt.toIso8601String(),
    "endAt": endAt.toIso8601String(),
    "available": available,
  };
}
