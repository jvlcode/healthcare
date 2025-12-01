class DoctorApplicationForm {
  Map<String, dynamic> step1PersonalInfo;
  Map<String, dynamic> step2ClinicInfo;
  List<Map<String, String>> step3Documents;
  bool isSubmitted;

  DoctorApplicationForm({
    Map<String, dynamic>? step1PersonalInfo,
    Map<String, dynamic>? step2ClinicInfo,
    List<Map<String, String>>? step3Documents,
    this.isSubmitted = false,
  }) : step1PersonalInfo = step1PersonalInfo ?? {},
       step2ClinicInfo = step2ClinicInfo ?? {},
       step3Documents = step3Documents ?? [];

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'step1PersonalInfo': step1PersonalInfo,
      'step2ClinicInfo': step2ClinicInfo,
      'step3Documents': step3Documents,
      'isSubmitted': isSubmitted,
    };
  }

  /// Safe JSON parser
  factory DoctorApplicationForm.fromJson(Map<String, dynamic> json) {
    return DoctorApplicationForm(
      step1PersonalInfo: json['step1PersonalInfo'] is Map
          ? Map<String, dynamic>.from(json['step1PersonalInfo'])
          : {},
      step2ClinicInfo: json['step2ClinicInfo'] is Map
          ? Map<String, dynamic>.from(json['step2ClinicInfo'])
          : {},
      step3Documents: (json['step3Documents'] is List)
          ? (json['step3Documents'] as List)
                .map(
                  (doc) => doc is Map
                      ? Map<String, String>.from(
                          doc.map(
                            (k, v) => MapEntry(k.toString(), v.toString()),
                          ),
                        )
                      : <String, String>{},
                )
                .toList()
          : [],
      isSubmitted: json['isSubmitted'] ?? false,
    );
  }

  /// Empty object (all defaults)
  factory DoctorApplicationForm.empty() {
    return DoctorApplicationForm(
      step1PersonalInfo: {},
      step2ClinicInfo: {},
      step3Documents: [],
      isSubmitted: false,
    );
  }
}
