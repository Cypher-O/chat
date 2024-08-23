import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:chat/model/conversation.dart'; // Adjust import based on your project structure

class WebSocketService extends ChangeNotifier {
  WebSocketChannel? _channel;
  final StreamController<Conversation> _messageController = StreamController<Conversation>.broadcast();

  Future<void> connect(String token) async {
    final url = "wss://chat-api-ey7r.onrender.com/ws?token=$token";
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      debugPrint("Connected to WebSocket successfully");

      // Listen to incoming messages
      _channel!.stream.listen((message) {
        final data = jsonDecode(message);
        final conversation = Conversation.fromMap(data); // Adjust as necessary
        _messageController.add(conversation);
      }, onError: (error) {
        debugPrint("WebSocket error: $error");
        _messageController.addError(error);
      }, onDone: () {
        debugPrint("WebSocket closed");
      });
    } catch (e) {
      debugPrint('Error connecting to WebSocket: $e');
    }
  }

  void sendMessage(String recipientId, String content) {
    if (_channel != null) {
      final message = {
        'recipientId': recipientId,
        'content': content,
      };
      _channel!.sink.add(jsonEncode(message));
      debugPrint("Message sent successfully");
    } else {
      debugPrint('Error: WebSocket channel is not connected.');
    }
  }

  Stream<Conversation> get messageStream => _messageController.stream;

  void disconnect() {
    _channel?.sink.close();
    _messageController.close();
  }
}



// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

// class WebSocketService extends ChangeNotifier {
//   WebSocketChannel? channel;

//   Future<void> connect(String token) async {
//     final url = "wss://chat-api-ey7r.onrender.com/ws?token=$token";
//     try {
//       channel = await WebSocketChannel.connect(Uri.parse(url));
//       debugPrint("Connected to websocket successfully");
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error connecting to WebSocket: $e');
//     }
//   }

//   void sendMessage(String recipientId, String content) {
//     if (channel != null) {
//       final message = {
//         'recipientId': recipientId,
//         'content': content,
//       };
//       channel!.sink.add(jsonEncode(message));
//       debugPrint("message sent successfully");
//     } else {
//       debugPrint('Error: WebSocket channel is not connected.');
//     }
//   }

//   Stream? get messages => channel?.stream;

//   void disconnect() {
//     channel?.sink.close();
//   }
// }