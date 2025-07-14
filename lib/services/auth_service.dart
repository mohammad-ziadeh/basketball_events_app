import 'dart:convert';
import 'package:fiba_3x3/services/storage_service.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://192.168.1.159:8000';
    } else if (Platform.isAndroid || Platform.isIOS) {
      return 'http://192.168.1.159:8000';
    } else {
      return 'http://192.168.1.159:8000';
    }
  }
}

class AuthService {
  final baseUrl = ApiConfig.baseUrl;

  final IStorage _storage = kIsWeb ? WebStorage() : MobileStorage();

  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {'Accept': 'application/json'},
      body: {'email': email, 'password': password},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: 'token', value: data['token']);
      await _storage.write(key: 'user', value: jsonEncode(data['user']));
      return null;
    } else {
      final error = jsonDecode(response.body)['message'];
      return error ?? 'Login failed';
    }
  }

  Future<String?> register({
    required String firstName,
    required String lastName,
    required String gender,
    required String birthDate,
    required String role,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/register'),
      headers: {'Accept': 'application/json'},
      body: {
        'first_name': firstName,
        'last_name': lastName,
        'gender': gender.toLowerCase(),
        'birth_date': birthDate,
        'role': role,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await _storage.write(key: 'token', value: data['token']);
      await _storage.write(key: 'user', value: jsonEncode(data['user']));
      return null;
    } else {
      try {
        final errorResponse = jsonDecode(response.body);
        if (errorResponse is Map && errorResponse.containsKey('message')) {
          return errorResponse['message'];
        }
        return 'Registration failed';
      } catch (e) {
        return 'Registration failed';
      }
    }
  }

  Future<Map<String, dynamic>?> getUser() async {
    final token = await _storage.read(key: 'token');
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/api/user'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return null;
  }

  Future<void> logout() async {
    final token = await _storage.read(key: 'token');
    if (token != null) {
      await http.post(
        Uri.parse('$baseUrl/api/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
    }
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'user');
  }

  Future<String?> sendVerificationCode() async {
    final token = await _storage.read(key: 'token');
    if (token == null) return 'Not authenticated';

    final response = await http.post(
      Uri.parse('$baseUrl/api/send-verification-code'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return null; // success
    } else {
      try {
        final error = jsonDecode(response.body);
        return error['message'] ?? 'Failed to send verification code';
      } catch (e) {
        return 'Failed to send verification code';
      }
    }
  }

  Future<String?> verifyEmailCode(String code) async {
    final token = await _storage.read(key: 'token');
    if (token == null) return 'Not authenticated';

    final response = await http.post(
      Uri.parse('$baseUrl/api/verify-email-code'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      body: {'code': code},
    );

    if (response.statusCode == 200) {
      // Optionally refresh and save the user again
      final userResponse = await getUser();
      if (userResponse != null) {
        await _storage.write(key: 'user', value: jsonEncode(userResponse));
      }
      return null; // success
    } else {
      try {
        final error = jsonDecode(response.body);
        return error['message'] ?? 'Invalid verification code';
      } catch (e) {
        return 'Invalid verification code';
      }
    }
  }
  
}
