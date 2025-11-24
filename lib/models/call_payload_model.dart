class CallPayload {
  final String callerId;
  final String receiverId;
  final String appointmentId;
  final String? roomId;
  final String? startTime;
  final String? endTime;
  final String? reason;
  final String? doctorName;
  final String? patientName;

  CallPayload({
    required this.callerId,
    required this.receiverId,
    required this.appointmentId,
    this.roomId,
    this.startTime,
    this.endTime,
    this.reason,
    this.doctorName,
    this.patientName,
  });

  factory CallPayload.fromJson(Map<String, dynamic> json) => CallPayload(
    callerId: json['callerId'],
    receiverId: json['receiverId'],
    appointmentId: json['appointmentId'],
    roomId: json['roomId'],
    startTime: json['startTime'],
    endTime: json['endTime'],
    reason: json['reason'],
    doctorName: json['doctorName'],
    patientName: json['patientName'],
  );

  Map<String, dynamic> toJson() => {
    'callerId': callerId,
    'receiverId': receiverId,
    'appointmentId': appointmentId,
    'roomId': roomId,
    'startTime': startTime,
    'endTime': endTime,
    'reason': reason,
    'doctorName': doctorName,
    'patientName': patientName,
  };
}
