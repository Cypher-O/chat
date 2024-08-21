import 'package:chat/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiServiceProvider extends ChangeNotifier {
  final ApiService _apiService;

  ApiServiceProvider() : _apiService = ApiService();

  Future<String?> getToken() async {
    return await _apiService.getToken();
  }

  Future<http.Response> registerUser(Map<String, dynamic> userData) {
    return _apiService.registerUser(userData);
  }

  Future<http.Response> loginUser(Map<String, dynamic> credentials) {
    return _apiService.loginUser(credentials);
  }

  Future<http.Response> getConversations() {
    return _apiService.getConversations();
  }

  Future<http.Response> sendMessage(Map<String, dynamic> messageData) {
    return _apiService.sendMessage(messageData);
  }
}