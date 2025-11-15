import 'api_client.dart';

class SlotService {
  final ApiClient _apiClient = ApiClient();

  /// -------------------------------
  /// GET SLOT LIST
  /// -------------------------------
  Future<Map<String, dynamic>> getSlotList(String doctorId) async {
    return await _apiClient.get("slots", queryParams: {"doctor": doctorId});
  }

  /// -------------------------------
  /// CREATE SLOT
  /// -------------------------------
  Future<Map<String, dynamic>> createSlot({
    required String date, // format: "YYYY-MM-DD"
    required String startTime, // format: "HH:mm"
    required String endTime, // format: "HH:mm"
  }) async {
    final slotData = {"date": date, "startTime": startTime, "endTime": endTime};

    return await _apiClient.post("slots", slotData, useAuth: true);
  }

  /// -------------------------------
  /// UPDATE SLOT
  /// -------------------------------
  Future<Map<String, dynamic>> updateSlot({
    required slotId,
    required String date, // format: "YYYY-MM-DD"
    required String startTime, // format: "HH:mm"
    required String endTime, // format: "HH:mm"
  }) async {
    final slotData = {"date": date, "startTime": startTime, "endTime": endTime};
    return await _apiClient.put("slots/$slotId", slotData, useAuth: true);
  }

  /// -------------------------------
  /// DELETE SLOT
  /// -------------------------------
  Future<bool> deleteSlot(String slotId) async {
    final res = await _apiClient.delete("slots/$slotId", useAuth: true);
    print(res);
    return res["success"] == true;
  }
}
