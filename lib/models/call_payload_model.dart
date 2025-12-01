class CallPayload {
  final String doctorId;
  final String patientId;
  final String appointmentId;
  final String? roomId;
  final String? startTime;
  final String? endTime;
  final String? reason;
  final String? doctorName;
  final String? patientName;
  final String? fromUserId;
  final String toUserId;
  final String? callerName;

  CallPayload({
    this.callerName,
    this.fromUserId,
    required this.toUserId,
    required this.doctorId,
    required this.patientId,
    required this.appointmentId,
    this.roomId,
    this.startTime,
    this.endTime,
    this.reason,
    this.doctorName,
    this.patientName,
  });

  /// Safe JSON parser
  factory CallPayload.fromJson(Map<String, dynamic> json) {
    return CallPayload(
      callerName: json['callerName']?.toString(),
      appointmentId: json['appointmentId']?.toString() ?? "",
      roomId: json['roomId']?.toString(),
      startTime: json['startTime']?.toString(),
      endTime: json['endTime']?.toString(),
      reason: json['reason']?.toString(),
      doctorName: json['doctorName']?.toString(),
      patientName: json['patientName']?.toString(),
      doctorId: json['doctorId']?.toString() ?? "",
      patientId: json['patientId']?.toString() ?? "",
      fromUserId: json['fromUserId']?.toString(),
      toUserId: json['toUserId']?.toString() ?? "",
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
    'fromUserId': fromUserId,
    'toUserId': toUserId,
    'doctorId': doctorId,
    'patientId': patientId,
    'appointmentId': appointmentId,
    'roomId': roomId,
    'startTime': startTime,
    'endTime': endTime,
    'reason': reason,
    'doctorName': doctorName,
    'patientName': patientName,
    'callerName': callerName,
  };

  /// Empty object
  factory CallPayload.empty() {
    return CallPayload(
      doctorId: "",
      patientId: "",
      appointmentId: "",
      toUserId: "",
      fromUserId: null,
      roomId: null,
      startTime: null,
      endTime: null,
      reason: null,
      doctorName: null,
      patientName: null,
      callerName: null,
    );
  }
}
