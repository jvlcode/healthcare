class Slot {
  String id;
  DateTime date;
  String startTime;
  String endTime;
  String dateLabel;
  String startTimeLabel;
  String endTimeLabel;
  bool available;

  Slot({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.dateLabel,
    required this.startTimeLabel,
    required this.endTimeLabel,
    required this.available,
  });

  DateTime get startDateTime {
    // assuming slot.date is in "YYYY-MM-DD"

    // startTime is like "13:00"
    final parts = startTime.split(":");
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  DateTime get endDateTime {
    // assuming slot.date is in "YYYY-MM-DD"
    final date = DateTime.parse(endTime);

    // startTime is like "13:00"
    final parts = endTime.split(":");
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  factory Slot.fromJson(Map<String, dynamic> json) {
    try {
      return Slot(
        id: json["_id"] ?? json["id"], // support both _id and id
        date: DateTime.parse(json["date"]),
        startTime: json["startTime"],
        endTime: json["endTime"],
        dateLabel: json["dateLabel"],
        startTimeLabel: json["startTimeLabel"],
        endTimeLabel: json["endTimeLabel"],
        available: json["available"] ?? false,
      );
    } catch (e, stack) {
      print('❌ Failed to parse Slot: $e');
      print('Stack: $stack');
      print('Raw JSON: $json');
      rethrow;
    }
  }
  Slot copyWith({
    String? id,
    String? startTime,
    String? endTime,
    String? startTimeLabel,
    String? endTimeLabel,
  }) {
    return Slot(
      id: id ?? this.id,
      date: date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      startTimeLabel: startTimeLabel ?? this.startTimeLabel,
      endTimeLabel: endTimeLabel ?? this.endTimeLabel,
      dateLabel: dateLabel,
      available: available,
    );
  }

  /// Convert Slot to JSON
  Map<String, dynamic> toJson() => {
    "_id": id,
    "date": date.toIso8601String(),
    "startTime": startTime,
    "endTime": endTime,
    "dateLabel": dateLabel,
    "startTimeLabel": startTimeLabel,
    "endTimeLabel": endTimeLabel,
    "available": available,
  };
}
