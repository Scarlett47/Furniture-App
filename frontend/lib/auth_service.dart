import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';
  static const storage = FlutterSecureStorage();

  // Helper method to get headers with auth token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await storage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      if (token != null)
        'Authorization': 'Token $token', // Change 'Bearer' to 'Token'
    };
  }

  static Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  // Register method
  static Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      return _handleAuthResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }

  // Login method
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      return _handleAuthResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }

  // Validate token
  static Future<bool> validateToken(String? token) async {
    if (token == null) return false;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/validate-token/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token', // Change 'Bearer' to 'Token'
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Token validation error: $e');
      return false;
    }
  }

  // Handle authentication responses
  static Future<Map<String, dynamic>> _handleAuthResponse(
    http.Response response,
  ) async {
    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final token = responseData['token'];
      if (token != null) {
        await _storeUserData(token, responseData['user']);
        return {'success': true, 'token': token, 'user': responseData['user']};
      }
      return {'success': false, 'message': 'Token missing from response'};
    } else {
      return {
        'success': false,
        'message':
            responseData['error'] ??
            responseData['message'] ??
            'Authentication failed',
      };
    }
  }

  // Store user data
  static Future<void> _storeUserData(String token, dynamic userData) async {
    await storage.write(key: 'token', value: token);
    if (userData != null) {
      await storage.write(
        key: 'user_id',
        value: userData['id']?.toString() ?? '',
      );
      await storage.write(key: 'user_email', value: userData['email'] ?? '');
      await storage.write(key: 'username', value: userData['username'] ?? '');
    }
  }

  static Future<Map<String, dynamic>> sendPasswordResetEmail(
    String email,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/password/reset/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Reset instructions sent'};
      } else {
        return {
          'success': false,
          'message':
              responseData['error'] ?? 'Failed to send reset instructions',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error'};
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await storage.read(key: 'token');
    return token != null;
  }

  // Get profile data
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/me/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        return {'success': true, 'user': userData};
      } else if (response.statusCode == 401) {
        await logout();
        return {
          'success': false,
          'message': 'Authentication expired. Please login again.',
        };
      }

      final responseData = jsonDecode(response.body);
      return {
        'success': false,
        'message': responseData['error'] ?? 'Failed to fetch profile data.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }

  // Update profile
  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/users/me/'),
        headers: await _getHeaders(),
        body: jsonEncode(profileData),
      );

      if (response.statusCode == 200) {
        final updatedUser = jsonDecode(response.body);

        // Update stored user data
        if (updatedUser['email'] != null) {
          await storage.write(key: 'user_email', value: updatedUser['email']);
        }
        if (updatedUser['username'] != null) {
          await storage.write(key: 'username', value: updatedUser['username']);
        }

        return {
          'success': true,
          'user': updatedUser,
          'message': 'Амжилттай шинэчлэгдлээ',
        };
      } else if (response.statusCode == 401) {
        await logout();
        return {
          'success': false,
          'message': 'Authentication expired. Please login again.',
        };
      }

      final responseData = jsonDecode(response.body);
      return {
        'success': false,
        'message': responseData['error'] ?? 'Failed to update profile.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }

  // Change password
  static Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/change-password/'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Password changed successfully.'};
      }

      final responseData = jsonDecode(response.body);
      return {
        'success': false,
        'message': responseData['error'] ?? 'Failed to change password.',
      };
    } catch (e) {
      return {'success': false, 'message': 'Connection error: ${e.toString()}'};
    }
  }

  // Get current user data
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/me/'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401) {
        await logout();
        return null;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Logout method
  static Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/logout/'),
        headers: await _getHeaders(),
      );
    } finally {
      await storage.delete(key: 'token');
      await storage.delete(key: 'user_id');
      await storage.delete(key: 'user_email');
      await storage.delete(key: 'username');
    }
  }
}
