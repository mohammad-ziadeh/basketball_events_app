import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fiba_3x3/services/api_config.dart';

class PlayerLeaderboardEntry {
  final int playerId;
  final String name;
  final String teamName;
  final int points;

  PlayerLeaderboardEntry({
    required this.playerId,
    required this.name,
    required this.teamName,
    required this.points,
  });

  factory PlayerLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return PlayerLeaderboardEntry(
      playerId: json['player_id'] ?? 0,
      name: json['name'] ?? '',
      teamName: json['team_name'] ?? '',
      points: json['points'] ?? 0,
    );
  }
}

class TeamLeaderboardEntry {
  final int id;
  final String name;
  final int points;

  TeamLeaderboardEntry({
    required this.id,
    required this.name,
    required this.points,
  });

  factory TeamLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return TeamLeaderboardEntry(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      points: json['points'] ?? 0,
    );
  }
}

class LeaderboardService {
  static final String _baseUrl = ApiConfig.baseUrl;

  static Future<List<PlayerLeaderboardEntry>> fetchPlayerLeaderboard() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/leaderboard/players'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<PlayerLeaderboardEntry>.from(
        data.map((e) => PlayerLeaderboardEntry.fromJson(e)),
      );
    } else {
      throw Exception('Failed to load player leaderboard');
    }
  }

  static Future<List<TeamLeaderboardEntry>> fetchTeamLeaderboard() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/leaderboard/teams'),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<TeamLeaderboardEntry>.from(
        data.map((e) => TeamLeaderboardEntry.fromJson(e)),
      );
    } else {
      throw Exception('Failed to load team leaderboard');
    }
  }


}
