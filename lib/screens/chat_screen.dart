import 'dart:convert';

import 'package:chat/model/conversation.dart';
import 'package:chat/provider/api_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat/services/websocket_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late WebSocketService _webSocketService;
  List<dynamic> _messages = [];

  @override
  void initState() {
    super.initState();
    _webSocketService = Provider.of<WebSocketService>(context, listen: false);
    _loadConversations();
  }

Future<void> _loadConversations() async {
  final apiServiceProvider = Provider.of<ApiServiceProvider>(context, listen: false);
  try {
    final userResponse = await apiServiceProvider.getUserData();
    final userData = jsonDecode(userResponse.body);

    final userId = userData['data']['id']?.toString();
    if (userId != null && userId.isNotEmpty) {
      final recentConversationsResponse = await apiServiceProvider.getRecentConversations();
      final recentConversations = (jsonDecode(recentConversationsResponse.body)['data'] as List<dynamic>)
          .map((conversation) => Conversation.fromMap(conversation as Map<String, dynamic>))
          .toList();

      final conversationsResponse = await apiServiceProvider.getAllConversations(userId);
      final conversations = (jsonDecode(conversationsResponse.body)['data'] as List<dynamic>)
          .map((conversation) => Conversation.fromMap(conversation as Map<String, dynamic>))
          .toList();

      setState(() {
        _messages = [...recentConversations, ...conversations];
      });
    } else {
      debugPrint('Error: userId is null or empty');
    }
  } catch (e) {
    debugPrint('Error loading conversations: $e');
  }
}

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _webSocketService.sendMessage("recipientId", _messageController.text);
      _messageController.clear();
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Chat')),
    body: Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final conversation = _messages[index] as Conversation; // Ensure correct type
              return ListTile(title: Text(conversation.content));
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your message',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  @override
  void dispose() {
    _webSocketService.disconnect();
    super.dispose();
  }
}