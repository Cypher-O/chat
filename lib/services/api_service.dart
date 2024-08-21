import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class ApiService {
//   final String baseUrl = "https://chat-api-ey7r.onrender.com/api";
//   final storage = const FlutterSecureStorage();

//   Future<String?> getToken() async {
//     return await storage.read(key: 'token');
//   }

//   Future<http.Response> registerUser(Map<String, dynamic> userData) async {
//     final url = Uri.parse('$baseUrl/users/register');
//     return await http.post(url,
//         body: jsonEncode(userData), headers: _headers());
//   }

//   Future<http.Response> loginUser(Map<String, dynamic> credentials) async {
//     final url = Uri.parse('$baseUrl/users/login');
//     return await http.post(url,
//         body: jsonEncode(credentials), headers: _headers());
//   }

//   Future<http.Response> getUserData(String token) async {
//     final url = Uri.parse('$baseUrl/users/account');
//     return await http.get(url, headers: _headers(token));
//   }

class ApiService {
  final String baseUrl = "https://chat-api-ey7r.onrender.com/api";
  final storage = const FlutterSecureStorage();
  static const String _tokenKey = 'token';

  Future<String?> getToken() async {
    return await storage.read(key: _tokenKey);
  }

  Future<void> storeToken(String token) async {
    await storage.write(key: _tokenKey, value: token);
  }

  Future<http.Response> registerUser(Map<String, dynamic> userData) async {
    final url = Uri.parse('$baseUrl/users/register');
    return await http.post(url, body: jsonEncode(userData), headers: _headers());
  }

  Future<http.Response> loginUser(Map<String, dynamic> credentials) async {
    final url = Uri.parse('$baseUrl/users/login');
    final response = await http.post(url, body: jsonEncode(credentials), headers: _headers());
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      await storeToken(responseData['data']['token']);
    }
    return response;
  }

  Future<http.Response> getUserData(String token) async {
    final url = Uri.parse('$baseUrl/users/account');
    return await http.get(url, headers: _headers(token));
  }
  Future<http.Response> getRecentConversation(String token) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/messages/recent');
    return await http.get(url, headers: _headers(token));
  }

  Future<http.Response> getAllConversations(String token, String userId) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/messages/conversation/$userId');
    return await http.get(url, headers: _headers(token));
  }

  Future<http.Response> sendMessage(Map<String, dynamic> messageData) async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/messages');
    return await http.post(url,
        body: jsonEncode(messageData), headers: _headers(token));
  }

  Map<String, String> _headers([String? token]) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
