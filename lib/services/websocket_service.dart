import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService extends ChangeNotifier {
  WebSocketChannel? channel;

  Future<void> connect(String token) async {
    final url = "wss://chat-api-ey7r.onrender.com/ws?token=$token";
    try {
      channel = await WebSocketChannel.connect(Uri.parse(url));
      debugPrint("Connected to websocket successfully");
      notifyListeners();
    } catch (e) {
      debugPrint('Error connecting to WebSocket: $e');
    }
  }

  void sendMessage(String recipientId, String content) {
    if (channel != null) {
      final message = {
        'recipientId': recipientId,
        'content': content,
      };
      channel!.sink.add(jsonEncode(message));
      debugPrint("message sent successfully");
    } else {
      debugPrint('Error: WebSocket channel is not connected.');
    }
  }

  Stream? get messages => channel?.stream;

  void disconnect() {
    channel?.sink.close();
  }
}