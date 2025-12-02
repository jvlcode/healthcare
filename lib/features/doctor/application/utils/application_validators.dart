class ApplicationValidators {
  static bool validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) return false;
    return RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$",
    ).hasMatch(email.trim());
  }

  static bool validatePhone(String? phone) {
    if (phone == null || phone.trim().isEmpty) return false;
    return RegExp(r"^[0-9]{10,}$").hasMatch(phone.trim());
  }

  static bool validatePersonal({
    required String fullName,
    required String email,
    required String phone,
    required String qualification,
    required String specialization,
    required int experience,
  }) {
    if (fullName.trim().isEmpty) return false;
    if (!validateEmail(email)) return false;
    if (!validatePhone(phone)) return false;
    if (qualification.trim().isEmpty) return false;
    if (specialization.trim().isEmpty) return false;
    if (experience < 0) return false;
    return true;
  }

  static bool validateClinic({
    required String clinicName,
    required String clinicAddress,
  }) {
    return clinicName.trim().isNotEmpty && clinicAddress.trim().isNotEmpty;
  }

  static bool validateDocuments(
    List<Map<String, String>> uploadedDocs, {
    List<dynamic>? pickedFiles,
  }) {
    final hasUploaded = uploadedDocs.isNotEmpty;
    final hasPicked = (pickedFiles ?? []).isNotEmpty;
    return hasUploaded || hasPicked;
  }
}
