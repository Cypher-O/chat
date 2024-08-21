import 'dart:convert';

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
  
  Future<http.Response> getUserData() async {
  final token = await getToken();
  if (token != null) {
    final response = await _apiService.getUserData(token);
    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body);
      final userId = userData['data']['id']?.toString(); // Check for null and convert to String
      return response;
    } else {
      throw Exception('Failed to get user data');
    }
  } else {
    throw Exception('Token is null');
  }
}

  Future<http.Response> getRecentConversations() async {
    final token = await getToken();
    if (token != null) {
      return await _apiService.getRecentConversation(token);
    } else {
      throw Exception('Token is null');
    }
  }

  Future<http.Response> getAllConversations(String userId) async {
    final token = await getToken();
    if (token != null) {
      return await _apiService.getAllConversations(token, userId);
    } else {
      throw Exception('Token is null');
    }
  }

  Future<http.Response> sendMessage(Map<String, dynamic> messageData) {
    return _apiService.sendMessage(messageData);
  }
}
