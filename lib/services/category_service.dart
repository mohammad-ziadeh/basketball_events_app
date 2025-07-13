import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:fiba_3x3/services/storage_service.dart';
import 'package:fiba_3x3/services/api_config.dart';

class Category {
  final int id;
  final String name;
  final int capacity;

  Category({required this.id, required this.name, required this.capacity});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      capacity: json['capacity'] ?? 12,
    );
  }
}

class CategoryService {
  Future<String> fetchToken() async {
    final storage = kIsWeb ? WebStorage() : MobileStorage();
    return await storage.read(key: 'token') ?? '';
  }

  Future<List<Category>> getCategoriesByEvent(
    int eventId, {
    String email = "",
    String phone = "",
  }) async {
    final token = await fetchToken();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/events/$eventId/categories'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Category.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<void> assignTeamToCategory({
    required int teamId,
    required int categoryId,
    required int eventId,
    required String email,
    required String phone,
  }) async {
    final token = await fetchToken();
    final url =
        '${ApiConfig.baseUrl}/api/teams/$teamId/categories/$categoryId/assign';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'event_id': eventId, 'email': email, 'phone': phone}),
    );

    // print('POST $url');
    // print('Status code: ${response.statusCode}');
    // print('Response body: ${response.body}');

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      final message = body['message'] ?? 'Failed to assign team to category';
      throw Exception(message);
    }
  }
}
