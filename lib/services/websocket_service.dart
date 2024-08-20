import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  late WebSocketChannel channel;

  void connect(String token) {
    final url = "ws://chat-api-ey7r.onrender.com/ws?token=$token";
    channel = WebSocketChannel.connect(Uri.parse(url));
  }

  void sendMessage(String recipientId, String content) {
    final message = {
      'recipientId': recipientId,
      'content': content,
    };
    channel.sink.add(jsonEncode(message));
  }

  Stream get messages => channel.stream;

  void disconnect() {
    channel.sink.close();
  }
}
