import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl = "https://chat-api-ey7r.onrender.com/api";
  final storage = const FlutterSecureStorage();

  Future<String?> getToken() async {
    return await storage.read(key: 'token');
  }

  Future<http.Response> registerUser(Map<String, dynamic> userData) async {
    final url = Uri.parse('$baseUrl/users/register');
    return await http.post(url, body: jsonEncode(userData), headers: _headers());
  }

  Future<http.Response> loginUser(Map<String, dynamic> credentials) async {
    final url = Uri.parse('$baseUrl/users/login');
    return await http.post(url, body: jsonEncode(credentials), headers: _headers());
  }

  Future<http.Response> getConversations() async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/messages/recent');
    return await http.get(url, headers: _headers(token));
  }

  Future<http.Response> sendMessage(Map<String, dynamic> messageData) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/messages');
    return await http.post(url, body: jsonEncode(messageData), headers: _headers(token));
  }

  Map<String, String> _headers([String? token]) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
