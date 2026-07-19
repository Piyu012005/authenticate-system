import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/storage.dart';

class ApiService {
  // Base URL of our Laravel backend
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  /// Returns standard JSON headers for all requests
  static Map<String, String> _headers({bool requiresAuth = false}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requiresAuth) {
      final token = Storage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  /// Register a new user
  /// POST /api/register
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: _headers(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );
    return _handleResponse(response);
  }

  /// Login with email and password
  /// POST /api/login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: _headers(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return _handleResponse(response);
  }

  /// Get the authenticated user's profile
  /// GET /api/profile  (requires Bearer token)
  static Future<Map<String, dynamic>> profile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: _headers(requiresAuth: true),
    );
    return _handleResponse(response);
  }

  /// Logout and revoke current token
  /// POST /api/logout  (requires Bearer token)
  static Future<Map<String, dynamic>> logout() async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: _headers(requiresAuth: true),
    );
    return _handleResponse(response);
  }

  /// Parses the HTTP response and throws on error status codes
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    // Extract error message from validation errors or top-level message
    String errorMessage = body['message'] ?? 'An unexpected error occurred';

    // Handle Laravel validation errors (422)
    if (body.containsKey('errors')) {
      final errors = body['errors'] as Map<String, dynamic>;
      final firstError = errors.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        errorMessage = firstError.first.toString();
      }
    }

    throw Exception(errorMessage);
  }
}
