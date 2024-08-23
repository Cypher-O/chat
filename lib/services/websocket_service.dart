import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:chat/model/conversation.dart';

class WebSocketService extends ChangeNotifier {
  WebSocketChannel? _channel;
  final StreamController<Conversation> _messageController =
      StreamController<Conversation>.broadcast();
  bool _isConnected = false;
  String? _token;

  bool get isConnected => _isConnected;
  final List<Function(Conversation)> _updateCallbacks = [];

  Future<void> connect(String token) async {
    if (_isConnected && _token == token) return;

    _token = token;
    await _establishConnection();
  }

  Future<void> _establishConnection() async {
    final url = "wss://chat-api-ey7r.onrender.com/ws?token=$_token";
    try {
      _channel?.sink.close();
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _isConnected = true;
      log("Connected to WebSocket successfully");

      // _channel!.stream.listen((message) {
      //   final data = jsonDecode(message);
      //   final conversation = Conversation.fromMap(data);
      //   _messageController.add(conversation);
      // },
      _channel!.stream.listen((message) {
        log('WebSocket received message: $message');
        final data = jsonDecode(message);
        final conversation = Conversation.fromMap(data);
        _messageController.add(conversation);
        for (var callback in _updateCallbacks) {
          callback(conversation);
        }
      }, onError: (error) {
        log("WebSocket error: $error");
        _messageController.addError(error);
        _handleReconnection();
      }, onDone: () {
        log("Websocket closed");
        _isConnected = false;
        _handleReconnection();
      });

      notifyListeners();
    } catch (e) {
      log("Error connecting to WebSocket: $e");
      _handleReconnection();
    }
  }

  void _handleReconnection() {
    Future.delayed(const Duration(seconds: 30), () {
      if (!_isConnected && _token != null) {
        _establishConnection();
      }
    });
  }

  void registerUpdateCallback(Function(Conversation) callback) {
    _updateCallbacks.add(callback);
  }

  void unregisterUpdateCallback(Function(Conversation) callback) {
    _updateCallbacks.remove(callback);
  }

  void sendMessage(String recipientId, String content) {
    if (_isConnected) {
      final message = {
        'recipientId': recipientId,
        'content': content,
      };
      _channel!.sink.add(jsonEncode(message));
      log("Message sent successfully");
    } else {
      log("Error: WebSocket channel is not connected");
    }
  }

  Stream<Conversation> get messageStream => _messageController.stream;

  void disconnect() {
    if (_isConnected) {
      _channel?.sink.close();
      _isConnected = false;
      notifyListeners();
    }
  }
}
