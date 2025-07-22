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
  final int? userId;
  final String avatarUrl;
  final int assists;
  final int fouls;

  PlayerStat({
    required this.playerId,
    required this.playerName,
    required this.points,
    this.userId,
    required this.avatarUrl,
    required this.assists,
    required this.fouls,
  });

  factory PlayerStat.fromJson(Map<String, dynamic> json) {
    return PlayerStat(
      playerId: json['player_id'],
      playerName: json['player_name'],
      userId: json['user_id'] != null ? json['user_id'] as int : null,
      points: json['points'],
      assists: json['assists'],
      avatarUrl: json['avatar_url'] ?? '',
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
  final int categoryId;
  final int groupId;
  final int teamAId;
  final int teamBId;
  final Team teamA;
  final Team teamB;
  final DateTime? matchTime;
  final DateTime? start_time;
  final String? location;
  final String? round;
  final Category? category;
  String? groupName;

  Matchup({
    required this.id,
    required this.eventId,
    required this.categoryId,
    required this.groupId,
    required this.teamAId,
    required this.teamBId,
    required this.teamA,
    required this.teamB,
    this.groupName,
    this.matchTime,
    this.start_time,
    this.location,
    this.round,
    this.category,
  });

  Matchup copyWith({String? groupName}) {
    return Matchup(
      id: id,
      eventId: eventId,
      categoryId: categoryId,
      groupId: groupId,
      teamAId: teamAId,
      teamBId: teamBId,
      teamA: teamA,
      teamB: teamB,
      matchTime: matchTime,
      start_time: start_time,
      location: location,
      round: round,
      category: category,
      groupName: groupName ?? this.groupName,
    );
  }

  String get categoryName => category?.name ?? 'Unknown Category';

  factory Matchup.fromJson(Map<String, dynamic> json) {
    return Matchup(
      id: json['id'],
      eventId: json['event_id'],
      categoryId: json['category_id'],
      groupId: json['group_id'] ?? -1,
      teamAId: json['team_a_id'],
      teamBId: json['team_b_id'],
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
      groupName: json['group']?['name'] ?? json['group_name'],
    );
  }
}

class EventWithMatchups {
  final int id;
  final String title;
  final String eventCode;
  final List<CategoryWithGroups> categories;

  EventWithMatchups({
    required this.id,
    required this.title,
    required this.eventCode,
    required this.categories,
  });

  factory EventWithMatchups.fromJson(Map<String, dynamic> json) {
    return EventWithMatchups(
      id: json['id'],
      title: json['title'],
      eventCode: json['event_code'],
      categories:
          (json['categories'] as List<dynamic>)
              .map((cat) => CategoryWithGroups.fromJson(cat))
              .toList(),
    );
  }
}

class MatchupService {
  final String baseUrl = "http://192.168.1.159:8000/api";

  Future<List<EventWithMatchups>> fetchEventsWithMatchups() async {
    final response = await http.get(Uri.parse('$baseUrl/matchups'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => EventWithMatchups.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load matchups');
    }
  }

  List<Matchup> extractAllMatchups(List<EventWithMatchups> events) {
    final List<Matchup> allMatchups = [];

    for (var event in events) {
      for (var category in event.categories) {
        for (var group in category.groups) {
          for (var matchup in group.matchups) {
            allMatchups.add(matchup.copyWith(groupName: group.name));
          }
        }
      }
    }

    return allMatchups;
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

class CategoryWithGroups {
  final int id;
  final String name;
  final List<GroupWithMatchups> groups;
  final List<Team> teams;

  CategoryWithGroups({
    required this.id,
    required this.name,
    required this.groups,
    required this.teams,
  });

  factory CategoryWithGroups.fromJson(Map<String, dynamic> json) {
    return CategoryWithGroups(
      id: json['id'],
      name: json['name'],
      groups:
          (json['groups'] as List<dynamic>)
              .map((group) => GroupWithMatchups.fromJson(group))
              .toList(),
      teams:
          (json['teams'] as List<dynamic>)
              .map((t) => Team.fromJson(t))
              .toList(),
    );
  }
}

class GroupWithMatchups {
  final int id;
  final String name;
  final List<Matchup> matchups;

  GroupWithMatchups({
    required this.id,
    required this.name,
    required this.matchups,
  });

  factory GroupWithMatchups.fromJson(Map<String, dynamic> json) {
    return GroupWithMatchups(
      id: json['id'],
      name: json['name'],
      matchups:
          (json['matchups'] as List<dynamic>)
              .map((m) => Matchup.fromJson(m))
              .toList(),
    );
  }
}
