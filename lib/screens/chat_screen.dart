// import 'dart:convert';
// import 'package:chat/model/conversation.dart';
// import 'package:chat/provider/api_service_provider.dart';
// import 'package:chat/reusable_widgets/chat_bubble.dart';
// import 'package:chat/services/websocket_service.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class ChatScreen extends StatefulWidget {
//   final Conversation selectedConversation;
//   final String currentUserId;

//   const ChatScreen({
//     super.key,
//     required this.selectedConversation,
//     required this.currentUserId,
//   });

//   @override
//   ChatScreenState createState() => ChatScreenState();
// }

// class ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   late WebSocketService _webSocketService;
//   List<Conversation> _messages = [];

//   @override
//   void initState() {
//     super.initState();
//     _webSocketService = Provider.of<WebSocketService>(context, listen: false);
//     _loadConversation();
//   }

//   Future<void> _loadConversation() async {
//     final apiServiceProvider = Provider.of<ApiServiceProvider>(context, listen: false);
//     try {
//       final conversationsResponse = await apiServiceProvider.getAllConversations(widget.selectedConversation.senderId);
//       final conversations = (jsonDecode(conversationsResponse.body)['data'] as List<dynamic>)
//           .map((conversation) => Conversation.fromMap(conversation as Map<String, dynamic>))
//           .toList();

//       setState(() {
//         _messages = conversations;
//       });
//     } catch (e) {
//       debugPrint('Error loading conversation: $e');
//     }
//   }

//   void _sendMessage() {
//     if (_messageController.text.isNotEmpty) {
//       _webSocketService.sendMessage(widget.selectedConversation.recipientId, _messageController.text);
//       _messageController.clear();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.selectedConversation.senderUsername)),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 final conversation = _messages[index];
//                 final isFromSender = conversation.senderId == widget.currentUserId;
//                 return ChatBubble(
//                   message: conversation.content,
//                   isFromSender: isFromSender,
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: const InputDecoration(
//                       hintText: 'Enter your message',
//                     ),
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: _sendMessage,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _webSocketService.disconnect();
//     super.dispose();
//   }
// }


import 'dart:convert';

import 'package:chat/model/conversation.dart';
import 'package:chat/provider/api_service_provider.dart';
import 'package:chat/reusable_widgets/chat_bubble.dart';
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
  List<Conversation> _messages = [];
  String _userId = '';

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

      _userId = userData['data']['id']?.toString() ?? '';
      if (_userId.isNotEmpty) {
        final recentConversationsResponse = await apiServiceProvider.getRecentConversations();
        final recentConversations = (jsonDecode(recentConversationsResponse.body)['data'] as List<dynamic>)
            .map((conversation) => Conversation.fromMap(conversation as Map<String, dynamic>))
            .toList();

        final conversationsResponse = await apiServiceProvider.getAllConversations(_userId);
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
                final conversation = _messages[index];
                final isFromSender = conversation.senderId == _userId;
                return Column(
                  crossAxisAlignment: isFromSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    ChatBubble(
                      message: conversation.content,
                      isFromSender: isFromSender,
                    ),
                    if (index < _messages.length - 1 &&
                        (_messages[index + 1].senderId == conversation.senderId) !=
                            isFromSender)
                      const SizedBox(height: 8.0),
                  ],
                );
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