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
  set fromUserId (String value) {
      fromUserId = value;
  }
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

  factory CallPayload.fromJson(Map<String, dynamic> json) => CallPayload(
    callerName: json['callerName'],
    appointmentId: json['appointmentId'],
    roomId: json['roomId'],
    startTime: json['startTime'],
    endTime: json['endTime'],
    reason: json['reason'],
    doctorName: json['doctorName'],
    patientName: json['patientName'],
    doctorId: json['doctorId'],
    patientId: json['patientId'],
    fromUserId: json['fromUserId'],
    toUserId: json['toUserId'],
  );

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
  };
}
