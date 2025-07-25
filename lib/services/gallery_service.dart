import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class Event {
  final String title;

  Event({required this.title});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(title: json['title'] ?? '');
  }
}

class Gallery {
  final int id;
  final String type; // 'photo' or 'video'
  final String? photo; // relative path
  final String? video; // relative path
  final Event? event;

  Gallery({
    required this.id,
    required this.type,
    this.photo,
    this.video,
    this.event,
  });

  String get url {
    final baseStorageUrl = '${ApiConfig.baseUrl}/storage/';
    if (type == 'photo' && photo != null) {
      return baseStorageUrl + photo!;
    } else if (type == 'video' && video != null) {
      return baseStorageUrl + video!;
    }
    return '';
  }

  factory Gallery.fromJson(Map<String, dynamic> json) {
    return Gallery(
      id: json['id'],
      type: json['type'], // keep as 'photo' or 'video'
      photo: json['photo'],
      video: json['video'],
      event: json['event'] != null ? Event.fromJson(json['event']) : null,
    );
  }
}

class GalleryService {
  final String baseUrl = '${ApiConfig.baseUrl}/api/gallery';

  Future<List<Gallery>> fetchGalleries({
    String? type,
    String? eventTitle,
  }) async {
    final uri = Uri.parse(baseUrl).replace(
      queryParameters: {
        if (type != null && type.isNotEmpty && type != 'All')
          'type': type, // send 'photo' or 'video' as is
        if (eventTitle != null && eventTitle.isNotEmpty && eventTitle != 'All')
          'event_title': eventTitle,
      },
    );

    final response = await http.get(uri);

    print('Request URL: $uri');
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List)
            .map((json) => Gallery.fromJson(json))
            .toList();
      } else {
        throw Exception('API returned failure: ${data.toString()}');
      }
    } else {
      throw Exception(
        'Failed to load galleries, status: ${response.statusCode}',
      );
    }
  }
}
