import 'dart:convert';
import 'package:http/http.dart' as http;

/// Centralized API client for the Boss App.
/// Manages JWT authentication headers and request scoping.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  final String baseUrl = 'https://mobawi-backend-api.onrender.com';
  final String businessId = 'felixpinski';

  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  String? get token => _token;

  Map<String, String> get headers => {
        'Content-Type': 'application/json',
        'x-business-id': businessId,
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<http.Response> get(String path) async {
    return await http.get(Uri.parse('$baseUrl$path'), headers: headers);
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    return await http.post(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> put(String path, Map<String, dynamic> body) async {
    return await http.put(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> delete(String path) async {
    return await http.delete(Uri.parse('$baseUrl$path'), headers: headers);
  }
}
