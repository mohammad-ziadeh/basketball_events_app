import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class MatchSummary {
  final String matchTime;
  final int id;
  final String teamAName;
  final String teamBName;
  final String? winnerTeam;
  final PlayerStat? topAssistPlayer;
  final PlayerStat? highestScorePlayer;
  final TeamFoul? mostFoulTeam;
  final TeamPoint teamAPoints;
  final TeamPoint teamBPoints;
  final List<PlayerStat> allPlayerStats;
  final String? location;
  final String? round;
  final Category? category;
  final FinalScore finalScore;

  MatchSummary({
    required this.matchTime,
    required this.id,
    required this.teamAName,
    required this.teamBName,
    required this.winnerTeam,
    required this.topAssistPlayer,
    required this.highestScorePlayer,
    required this.mostFoulTeam,
    required this.teamAPoints,
    required this.teamBPoints,
    required this.allPlayerStats,
    required this.location,
    required this.round,
    required this.category,
    required this.finalScore,
  });

  factory MatchSummary.fromJson(Map<String, dynamic> json) {
    return MatchSummary(
      matchTime: json['match_time'] ?? '',
      id: json['id'] ?? 0,
      teamAName: json['team_a_name'] ?? '',
      teamBName: json['team_b_name'] ?? '',
      winnerTeam: json['winner_team'],
      topAssistPlayer:
          json['top_assist_player'] != null
              ? PlayerStat.fromJson(json['top_assist_player'])
              : null,
      highestScorePlayer:
          json['top_score_player'] != null
              ? PlayerStat.fromJson(json['top_score_player'])
              : null,
      mostFoulTeam:
          json['most_foul_team'] != null
              ? TeamFoul.fromJson(json['most_foul_team'])
              : null,
      teamAPoints: TeamPoint.fromJson(json['team_a_points']),
      teamBPoints: TeamPoint.fromJson(json['team_b_points']),
      allPlayerStats:
          (json['all_player_stats'] as List)
              .map((e) => PlayerStat.fromJson(e))
              .toList(),
      location: json['location'],
      round: json['round'],
      category:
          json['category'] != null ? Category.fromJson(json['category']) : null,
      finalScore: FinalScore.fromJson(json['final_score']),
    );
  }

  firstWhere(
    bool Function(dynamic e) param0, {
    required MatchSummary Function() orElse,
  }) {}
}

class Pivot {
  final String status;

  Pivot({required this.status});

  factory Pivot.fromJson(Map<String, dynamic> json) {
    return Pivot(status: json['status'] ?? '');
  }
}

class PlayerStat {
  final int playerId;
  final String playerName;
  final int points;
  final int assists;
  final int fouls;

  PlayerStat({
    required this.playerId,
    required this.playerName,
    required this.points,
    required this.assists,
    required this.fouls,
  });

  factory PlayerStat.fromJson(Map<String, dynamic> json) {
    return PlayerStat(
      playerId: json['player_id'],
      playerName: json['player_name'],
      points: json['points'],
      assists: json['assists'],
      fouls: json['fouls'],
    );
  }
}

class TeamFoul {
  final int teamId;
  final String teamName;
  final int fouls;

  TeamFoul({required this.teamId, required this.teamName, required this.fouls});

  factory TeamFoul.fromJson(Map<String, dynamic> json) {
    return TeamFoul(
      teamId: json['team_id'],
      teamName: json['team_name'],
      fouls: json['fouls'],
    );
  }
}

class FinalScore {
  final int teamA;
  final int teamB;

  FinalScore({required this.teamA, required this.teamB});

  factory FinalScore.fromJson(Map<String, dynamic> json) {
    return FinalScore(teamA: json['team_a'], teamB: json['team_b']);
  }
}

class TeamPoint {
  final int teamId;
  final String teamName;
  final int points;

  TeamPoint({
    required this.teamId,
    required this.teamName,
    required this.points,
  });

  factory TeamPoint.fromJson(Map<String, dynamic> json) {
    return TeamPoint(
      teamId: json['team_id'],
      teamName: json['team_name'],
      points: json['points'],
    );
  }
}

class MatchSummaryService {
  static Future<MatchSummary> fetchMatchSummary(int matchupId) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}/api/matchups/$matchupId/summary',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return MatchSummary.fromJson(jsonData);
    } else {
      throw Exception('Failed to load match summary');
    }
  }
}

class Team {
  final int id;
  final String name;
  final Category? category;
  final Pivot? pivot;

  Team({required this.id, required this.name, this.category, this.pivot});

  factory Team.fromJson(Map<String, dynamic> json) {
    final category =
        json['category'] != null ? Category.fromJson(json['category']) : null;

    return Team(
      id: json['id'],
      name: json['name'],
      pivot: json['pivot'] != null ? Pivot.fromJson(json['pivot']) : null,
      category: category,
    );
  }
}

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['id'], name: json['name']);
  }
}

class Matchup {
  final int id;
  final int eventId;
  final Team teamA;
  final Team teamB;
  final DateTime? matchTime;
  final DateTime? start_time;
  final String? location;
  final String? round;
  final Category? category;

  Matchup({
    required this.id,
    required this.eventId,
    required this.teamA,
    required this.teamB,
    this.matchTime,
    this.start_time,
    this.location,
    this.round,
    this.category,
  });

  String get categoryName => category?.name ?? 'Unknown';

  factory Matchup.fromJson(Map<String, dynamic> json) {
    return Matchup(
      id: json['id'],
      eventId: json['event_id'],
      teamA: Team.fromJson(json['team_a']),
      teamB: Team.fromJson(json['team_b']),
      matchTime:
          json['match_time'] != null
              ? DateTime.parse(json['match_time'])
              : null,
      start_time:
          json['start_time'] != null
              ? DateTime.parse(json['start_time'])
              : null,
      location: json['location'],
      round: json['round'],
      category:
          json['category'] != null ? Category.fromJson(json['category']) : null,
    );
  }
}

class EventWithMatchups {
  final int id;
  final String title;
  final String eventCode;
  final List<Team> teams;
  final List<Matchup> matchups;

  EventWithMatchups({
    required this.id,
    required this.title,
    required this.eventCode,
    required this.teams,
    required this.matchups,
  });

  factory EventWithMatchups.fromJson(Map<String, dynamic> json) {
    return EventWithMatchups(
      id: json['id'],
      title: json['title'],
      eventCode: json['event_code'],
      teams:
          (json['teams'] as List<dynamic>? ?? [])
              .map((t) => Team.fromJson(t))
              .toList(),
      matchups:
          (json['matchups'] as List<dynamic>? ?? [])
              .map((m) => Matchup.fromJson(m))
              .toList(),
    );
  }
}

class MatchupService {
  final String baseUrl = "http://192.168.1.159:8000/api";

  Future<List<EventWithMatchups>> fetchEventsWithMatchups() async {
    final response = await http.get(Uri.parse('$baseUrl/matchups'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((e) => EventWithMatchups.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load matchups');
    }
  }

  Future<Matchup> fetchMatchupDetails(int matchupId) async {
    final response = await http.get(Uri.parse('$baseUrl/matchups/$matchupId'));
    if (response.statusCode == 200) {
      return Matchup.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load matchup details');
    }
  }
}

class TeamsByCat {
  static const String baseUrl = "http://192.168.1.159:8000/api";

  static Future<Map<int, List<Team>>> fetchTeamsGroupedByCategory(
    int eventId,
  ) async {
    final url = Uri.parse('$baseUrl/events/$eventId/teams-by-category');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;

      final map = <int, List<Team>>{};

      data.forEach((categoryIdStr, teamsJson) {
        final categoryId = int.tryParse(categoryIdStr);
        if (categoryId != null && teamsJson is List) {
          map[categoryId] =
              (teamsJson).map<Team>((e) => Team.fromJson(e)).toList();
        }
      });

      return map;
    } else {
      throw Exception("Failed to load teams by category");
    }
  }
}
