import 'api_client.dart';

class ReviewService {
  final ApiClient _apiClient = ApiClient();

  // Submit a review
  Future<Map<String, dynamic>> submitReview({
    required String doctorId,
    required int rating,
    String? comment,
  }) async {
    final body = {
      "doctorId": doctorId,
      "rating": rating,
      if (comment != null && comment.isNotEmpty) "comment": comment,
    };

    return await _apiClient.post("reviews/add", body, useAuth: true);
  }

  // Get reviews for a doctor
  Future<Map<String, dynamic>> getReviewsForDoctor(String doctorId) async {
    return await _apiClient.get(
      "api/reviews?doctorId=$doctorId",
      useAuth: true,
    );
  }

  // Get rating stats for a doctor
  Future<Map<String, dynamic>> getRatingStats(String doctorId) async {
    return await _apiClient.get("reviews/stats?doctorId=$doctorId");
  }
}
