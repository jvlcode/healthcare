import 'package:healthcare/core/constants/urls.dart';

class ImageUtils {
  static const String fallbackUrl =
      'https://cdn-icons-png.flaticon.com/512/8815/8815112.png';
  static const String userAvatar = 'assets/images/user_avatar.png';

  static String baseUrl = AppUrls.baseUrl; // or your production base

  static String resolve(String? path) {
    if (path == null || path.isEmpty) return fallbackUrl;
    if (path.startsWith('http') || path.startsWith('https')) return path;
    return '$baseUrl/$path';
  }
}
