import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fiba_3x3/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'api_config.dart';

class UserNotification {
  final String id;
  final int eventId;
  final String eventTitle;
  final String message;
  final String assignedBy;
  final DateTime? startDate;
  final DateTime? endDate;
  final String coachName;
  final DateTime? readAt;

  UserNotification({
    required this.id,
    required this.eventId,
    required this.startDate,
    required this.endDate,
    required this.eventTitle,
    required this.message,
    required this.assignedBy,
    required this.coachName,
    this.readAt,
  });

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
      id: json['id'] ?? '',
      eventId: json['event_id'] ?? 0,
      eventTitle: json['event_title'] ?? 'No title',
      message: json['message'] ?? '',
      assignedBy: json['assigned_by'] ?? 'Unknown',
      coachName: json['coach_name'] ?? 'Unknown',
      startDate:
          json['start_date'] != null
              ? DateTime.tryParse(json['start_date'])
              : null,
      endDate:
          json['end_date'] != null ? DateTime.tryParse(json['end_date']) : null,
      readAt:
          json['read_at'] != null ? DateTime.tryParse(json['read_at']) : null,
    );
  }
}

class NotificationService {
  final String baseUrl = ApiConfig.baseUrl;
  final IStorage storage = kIsWeb ? WebStorage() : MobileStorage();

  Future<String?> _getToken() async => await storage.read(key: 'token');

  Future<List<UserNotification>> getNotifications() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/notifications'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is Map &&
          decoded.containsKey('data') &&
          decoded['data'] != null) {
        final List<dynamic> data = decoded['data'];
        return data.map((json) => UserNotification.fromJson(json)).toList();
      } else if (decoded is List) {
        return decoded.map((json) => UserNotification.fromJson(json)).toList();
      } else {
        throw Exception('Unexpected response format: $decoded');
      }
    } else {
      throw Exception(
        'Failed to fetch notifications (Status: ${response.statusCode})',
      );
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/notifications/$notificationId/read'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read');
    }
  }

  Future<void> markAllAsRead() async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/api/notifications/read-all'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark all notifications as read');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/notifications/$notificationId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete notification');
    }
  }

  Future<void> deleteAllNotifications() async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/notifications'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete all notifications');
    }
  }

  Future<int> getUnreadCount() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/api/notifications/unread-count'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return jsonBody['unread_count'];
    } else {
      throw Exception('Failed to load unread count');
    }
  }
}
