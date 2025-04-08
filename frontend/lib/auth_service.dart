import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = 'http://localhost:8000/api/auth'; // For
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Login failed: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('Login error: $e');
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }
}
