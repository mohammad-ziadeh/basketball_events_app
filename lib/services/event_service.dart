import 'dart:convert';
import 'package:http/http.dart' as http;

class EventLeaderboardEntry {
  final int teamId;
  final String teamName;
  final int points;

  EventLeaderboardEntry({
    required this.teamId,
    required this.teamName,
    required this.points,
  });

  factory EventLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return EventLeaderboardEntry(
      teamId: json['team_id'],
      teamName: json['team_name'],
      points: json['points'],
    );
  }
}

class Event {
  final int id;
  final String title;
  final String location;
  final DateTime startDate;
  final DateTime endDate;
  final String eventCode;
  final String? imageUrl;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.title,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.eventCode,
    required this.updatedAt,
    this.imageUrl,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    String? rawImage = json['image_url'];
    String? imageUrl;

    if (rawImage != null && rawImage.isNotEmpty) {
      final filename = rawImage.split('/').last;
      imageUrl = 'http://192.168.1.159:8000/cors-image/$filename';
    }

    return Event(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown Title',
      location: json['location'] ?? 'Unknown Location',
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      startDate: DateTime.parse(
        json['start_date'] ?? DateTime.now().toIso8601String(),
      ),
      endDate: DateTime.parse(
        json['end_date'] ?? DateTime.now().toIso8601String(),
      ),
      eventCode: json['event_code'] ?? '',
      imageUrl: imageUrl,
    );
  }
}

class EventService {
  final String apiUrl = "http://192.168.1.159:8000/api/events";
  final String apiUrlLeaderboard =
      "http://192.168.1.159:8000/api/events-leaderboard";

  Future<List<Event>> getEvents() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body);
      return body.map((dynamic item) => Event.fromJson(item)).toList();
    } else {
      throw "Failed to load events";
    }
  }

  Future<Event> fetchEventById(int id) async {
    final response = await http.get(Uri.parse('$apiUrl/$id'));
    if (response.statusCode == 200) {
      return Event.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load event');
    }
  }

  Future<List<EventLeaderboardEntry>> fetchEventLeaderboardById(int id) async {
    final response = await http.get(Uri.parse('$apiUrlLeaderboard/$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> leaderboardJson = data['leaderboard'];
      return leaderboardJson
          .map((e) => EventLeaderboardEntry.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to load event leaderboard');
    }
  }
}

Future<List<Event>> fetchEvents({
  String filter = 'upcoming',
  String? search,
  String? season,
  String? location,
}) async {
  final uri = Uri.parse(
    'http://192.168.1.159:8000/api/next-events/search',
  ).replace(
    queryParameters: {
      'filter': filter,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (season != null && season != 'Any season') 'season': season,
      if (location != null && location != 'Any location') 'location': location,
    },
  );

  final response = await http.get(uri);
  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((e) => Event.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load events');
  }
}

Future<List<String>> fetchSuggestions(String query) async {
  final uri = Uri.parse(
    'http://192.168.1.159:8000/api/next-events/suggestions',
  ).replace(queryParameters: {'q': query});

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((e) => e.toString()).toList();
  } else {
    throw Exception('Failed to fetch suggestions');
  }
}
