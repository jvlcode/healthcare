/// Example mapper: converts feature data to API payload shape.
/// Adjust fields if your backend expects different key names.
Map<String, dynamic> mapToApiPayload({
  required Map<String, dynamic> personal,
  required Map<String, dynamic> clinic,
  required List<Map<String, String>> documents,
}) {
  return {
    'personalInfo': personal,
    'clinicInfo': clinic,
    'documents': documents,
  };
}
