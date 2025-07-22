import 'dart:convert';
import 'package:fiba_3x3/services/api_config.dart';
import 'package:http/http.dart' as http;

class Player {
  final int id;
  final String name;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? gender;
  final String? birthDate;
  final String? role;
  final int points;
  final String rank;
  final String? avatarUrl;
  final String? backgroundUrl;
  final List<PlayerEvent> events;
  final List<Badge> badges;

  Player({
    required this.id,
    required this.name,
    this.firstName,
    this.lastName,
    this.email,
    this.gender,
    this.birthDate,
    this.role,
    required this.points,
    required this.rank,
    this.avatarUrl,
    this.backgroundUrl,
    required this.events,
    required this.badges,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      gender: json['gender'],
      birthDate: json['birth_date'],
      role: json['role'],
      points: json['points'] ?? 0,
      rank: json['rank'] ?? 'N/A',
      avatarUrl: json['avatar_url'],
      backgroundUrl: json['background_url'],
      events:
          json['events'] != null
              ? (json['events'] as List)
                  .map((e) => PlayerEvent.fromJson(e))
                  .toList()
              : [],
      badges:
          json['badges'] != null
              ? (json['badges'] as List).map((e) => Badge.fromJson(e)).toList()
              : [],
    );
  }
}

class PlayerEvent {
  final String eventName;
  final int points;
  final String teamName;
  // final String dateRange;
  final String startDate;
  final int eventId;
  final String categoryName;
  PlayerEvent({
    required this.eventName,
    required this.points,
    required this.categoryName,
    required this.eventId,
    required this.teamName,
    // required this.dateRange,
    required this.startDate,
  });

  factory PlayerEvent.fromJson(Map<String, dynamic> json) {
    return PlayerEvent(
      eventName: json['event_name'] ?? 'N/A',
      points: json['points'] ?? 0,
      eventId: json['event_id'] ?? 0,
      teamName: json['team_name'] ?? 'N/A',
      startDate: json['start_date'] ?? 'N/A',
      // dateRange: json['date_range'] ?? 'N/A',
      categoryName: json['category_name'] ?? 'N/A',
    );
  }
}

class Badge {
  final String title;
  final bool unlocked;

  Badge({required this.title, required this.unlocked});

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      title: json['title'] ?? '',
      unlocked: json['unlocked'] ?? false,
    );
  }
}

class EventInfo {
  final String eventName;
  final int points;
  final String? teamName;
  final String dateRange;

  EventInfo({
    required this.eventName,
    required this.points,
    this.teamName,
    required this.dateRange,
  });

  factory EventInfo.fromJson(Map<String, dynamic> json) {
    return EventInfo(
      eventName: json['event_name'],
      points: json['points'],
      teamName: json['team_name'],
      dateRange: json['start_date'],
    );
  }
}

class PlayerService {
  static final String baseUrl = '${ApiConfig.baseUrl}/api/player-profile';

  static Future<Player> fetchPlayerProfile(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Player.fromJson(data);
    } else {
      throw Exception('Failed to load player profile');
    }
  }
}
