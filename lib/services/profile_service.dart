import 'dart:convert';
import 'package:fiba_3x3/services/api_config.dart';
import 'package:http/http.dart' as http;
import 'package:fiba_3x3/services/storage_service.dart';
import 'package:flutter/foundation.dart';
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';
import 'dart:io';

class Profile {
  final int id;
  final String firstName;
  final String lastName;
  final String name;
  final String email;
  final String gender;
  final String birthDate;
  final String role;
  final int points;
  final String rank;
  final String avatarUrl;
  final String backgroundUrl;
  final List<PlayerEvent> events;
  final List<Badge> badges;

  Profile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.name,
    required this.email,
    required this.gender,
    required this.birthDate,
    required this.role,
    required this.points,
    required this.rank,
    required this.avatarUrl,
    required this.backgroundUrl,
    required this.events,
    required this.badges,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    var eventsJson = json['events'] as List<dynamic>? ?? [];
    var badgesJson = json['badges'] as List<dynamic>? ?? [];

    List<PlayerEvent> events =
        eventsJson.map((item) => PlayerEvent.fromJson(item)).toList();

    List<Badge> badges =
        badgesJson.map((item) => Badge.fromJson(item)).toList();

    return Profile(
      id: json['id'] ?? 0,
      firstName: (json['first_name'] as String?) ?? '',
      lastName: (json['last_name'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      gender: (json['gender'] as String?) ?? '',
      birthDate: (json['birth_date'] as String?) ?? '',
      role: (json['role'] as String?) ?? '',
      points: json['points'] ?? 0,
      rank: (json['rank'] as String?) ?? 'N/A',
      avatarUrl: json['avatar_url'] as String? ?? '',
      backgroundUrl: json['background_url'] as String? ?? '',
      events: events,
      badges: badges,
    );
  }
}

class PlayerEvent {
  final int eventId;
  final String eventName;
  final int points;
  final String teamName;
  final String categoryName;
  // final String dateRange;
  final String startDate;

  PlayerEvent({
    required this.eventName,
    required this.eventId,
    required this.points,
    required this.teamName,
    required this.categoryName,
    // required this.dateRange,
    required this.startDate,
  });

  factory PlayerEvent.fromJson(Map<String, dynamic> json) {
    return PlayerEvent(
      eventId: json['event_id'],
      eventName: json['event_name'],
      points: json['points'],
      teamName: json['team_name'] ?? 'N/A',
      categoryName: json['category_name'] ?? 'N/A',
      startDate: json['date_range'] ?? 'N/A',
      // dateRange: json['date_range'] ?? 'N/A',
    );
  }
}

class Badge {
  final String title;
  final bool unlocked;

  Badge({required this.title, required this.unlocked});

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(title: json['title'], unlocked: json['unlocked']);
  }
}

class ProfileService {
  final String baseUrl = ApiConfig.baseUrl;
  final IStorage _storage = kIsWeb ? WebStorage() : MobileStorage();

  Future<Profile> fetchProfile() async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      throw Exception('No authentication token found.');
    }
    final response = await http.get(
      Uri.parse('$baseUrl/api/profile'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Profile.fromJson(jsonData);
    } else {
      throw Exception('Failed to load profile: ${response.reasonPhrase}');
    }
  }

  Future<void> uploadProfileImage(String type, File imageFile) async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      throw Exception('No authentication token found.');
    }

    final uri = Uri.parse('$baseUrl/api/profile/upload-image');

    final request =
        http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = 'Bearer $token'
          ..fields['type'] = type
          ..files.add(
            await http.MultipartFile.fromPath(
              'image',
              imageFile.path,
              contentType: MediaType('image', 'jpeg'),
            ),
          );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception(error['message'] ?? 'Failed to upload image');
    }
  }

  static Future<int?> getLoggedInUserId() async {
    final IStorage storage = kIsWeb ? WebStorage() : MobileStorage();
    final token = await storage.read(key: 'token');
    if (token == null) return null;

    final String url = '${ApiConfig.baseUrl}/api/user';
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final user = jsonDecode(response.body);
      return user['id'] as int?;
    }

    return null;
  }
}
