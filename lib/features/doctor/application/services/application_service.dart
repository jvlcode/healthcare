import 'package:healthcare/services/doctor_service.dart';

/// Thin adapter — keeps controller testable and isolated.
/// You can add more behavior (retry, transform) here in future.
class ApplicationService {
  final DoctorService _doctorService = DoctorService();

  Future<Map<String, dynamic>> submit({
    required Map<String, dynamic> personalInfo,
    required Map<String, dynamic> clinicInfo,
    required List<Map<String, String>> documents,
  }) async {
    return await _doctorService.submitApplication(
      personalInfo: personalInfo,
      clinicInfo: clinicInfo,
      documents: documents,
    );
  }
}
