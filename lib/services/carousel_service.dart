import 'dart:convert';
import 'package:fiba_3x3/services/api_config.dart';
import 'package:http/http.dart' as http;

class Carousel {
  final int id;
  final String? imageUrl;
  final String tag;
  final String title;
  final int updatedAt;

  Carousel({
    required this.id,
    required this.imageUrl,
    required this.tag,
    required this.title,
    required this.updatedAt,
  });

  factory Carousel.fromJson(Map<String, dynamic> json) {
    return Carousel(
      id: json['id'] ?? 0,
      imageUrl: json['image_url'] as String?,
      tag: json['tag'] ?? '',
      title: json['title'] ?? '',
      updatedAt: json['updated_at'] ?? 0,
    );
  }
}

class CarouselService {
  static Future<List<Carousel>> fetchCarouselData({int retries = 3}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/carousel');
    int attempt = 0;

    while (attempt < retries) {
      try {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final List<dynamic> jsonList = json.decode(response.body);
          return jsonList
              .map((jsonItem) => Carousel.fromJson(jsonItem))
              .toList();
        } else {
          throw Exception(
            'Failed to load carousel data: HTTP ${response.statusCode}',
          );
        }
      } catch (e) {
        attempt++;
        if (attempt >= retries) rethrow;
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    throw Exception('Failed to fetch carousel data after $retries attempts.');
  }
}
