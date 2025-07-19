import 'dart:convert';

import 'package:http/http.dart' as http;

class Player {
  final int id;
  final String name;
  // final String city;
  // final String country;
  final String gender;
  final String avatarUrl;
  final String ageCategory;

  Player({
    required this.id,
    required this.name,
    // required this.city,
    // required this.country,
    required this.avatarUrl,

    required this.gender,
    required this.ageCategory,
  });

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'],
    name: json['name'],
    // city: json['city'],
    // country: json['country'],
    gender: json['gender'],
    avatarUrl:
        json['avatar_url'],
    ageCategory: json['age_category'],
  );
}

Future<List<Player>> fetchPlayers({String? search}) async {
  final uri = Uri.parse('http://192.168.1.159:8000/api/players/search').replace(
    queryParameters: {
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    },
  );

  final response = await http.get(uri);
  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((e) => Player.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load players');
  }
}

Future<List<String>> fetchPlayerSuggestions(String query) async {
  final uri = Uri.parse(
    'http://192.168.1.159:8000/api/players/suggestions',
  ).replace(queryParameters: {'q': query});

  final response = await http.get(uri);
  if (response.statusCode == 200) {
    final List<dynamic> jsonData = json.decode(response.body);
    return jsonData.map((e) => e.toString()).toList();
  } else {
    throw Exception('Failed to fetch player suggestions');
  }
}
