class DoctorApplicationForm {
  Map<String, dynamic>? step1PersonalInfo;
  Map<String, dynamic>? step2ClinicInfo;
  List<Map<String, String>>? step3Documents;
  bool isSubmitted;

  DoctorApplicationForm({
    this.step1PersonalInfo,
    this.step2ClinicInfo,
    this.step3Documents,
    this.isSubmitted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'step1PersonalInfo': step1PersonalInfo,
      'step2ClinicInfo': step2ClinicInfo,
      'step3Documents': step3Documents,
      'isSubmitted': isSubmitted,
    };
  }

  factory DoctorApplicationForm.fromJson(Map<String, dynamic> json) {
    return DoctorApplicationForm(
      step1PersonalInfo: Map<String, dynamic>.from(
        json['step1PersonalInfo'] ?? {},
      ),
      step2ClinicInfo: Map<String, dynamic>.from(json['step2ClinicInfo'] ?? {}),
      step3Documents: (json['step3Documents'] as List?)
          ?.map((doc) => Map<String, String>.from(doc))
          .toList(),
      isSubmitted: json['isSubmitted'] ?? false,
    );
  }
}
