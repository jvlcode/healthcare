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

  factory Slot.fromJson(Map<String, dynamic> json) {
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
}
