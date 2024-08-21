import 'dart:convert';
import 'package:chat/model/conversation.dart';
import 'package:chat/provider/api_service_provider.dart';
import 'package:chat/reusable_widgets/chat_bubble.dart';
import 'package:chat/services/websocket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final Conversation selectedConversation;
  final String currentUserId;

  const ChatScreen({
    super.key,
    required this.selectedConversation,
    required this.currentUserId,
  });

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late WebSocketService _webSocketService;
  List<Conversation> _messages = [];

  @override
  void initState() {
    super.initState();
    _webSocketService = Provider.of<WebSocketService>(context, listen: false);
    _loadConversation();
  }

  Future<void> _loadConversation() async {
    final apiServiceProvider =
        Provider.of<ApiServiceProvider>(context, listen: false);
    try {
      final conversationsResponse = await apiServiceProvider
          .getAllConversations(widget.selectedConversation.senderId);
      final conversations =
          (jsonDecode(conversationsResponse.body)['data'] as List<dynamic>)
              .map((conversation) =>
                  Conversation.fromMap(conversation as Map<String, dynamic>))
              .toList();

      setState(() {
        _messages = conversations;
      });
    } catch (e) {
      debugPrint('Error loading conversation: $e');
    }
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      _webSocketService.sendMessage(
          widget.selectedConversation.recipientId, _messageController.text);
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.selectedConversation.senderUsername)),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final conversation = _messages[index];
                  final isFromSender =
                      conversation.senderId == widget.currentUserId;
                  return ChatBubble(
                    message: conversation.content,
                    isFromSender: isFromSender,
                  );
                },
              ),
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
