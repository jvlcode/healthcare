import 'package:hive/hive.dart';

part 'doctor_application_form_model.g.dart';

@HiveType(typeId: 11)
class DoctorApplicationForm extends HiveObject {
  @HiveField(0)
  Map<String, dynamic>? step1PersonalInfo;

  @HiveField(1)
  Map<String, dynamic>? step2ClinicInfo;

  @HiveField(2)
  List<Map<String, String>>? step3Documents; // <-- now stores objects

  @HiveField(3)
  bool isSubmitted = false;
}
