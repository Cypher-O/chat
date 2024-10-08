import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:chat/model/conversation.dart';
import 'package:chat/provider/api_service_provider.dart';
import 'package:chat/reusable_widgets/chat_bubble.dart';
import 'package:chat/services/websocket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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
  late ApiServiceProvider _apiServiceProvider;
  List<Conversation> _messages = [];
  late StreamSubscription<Conversation> _messageSubscription;

  @override
  void initState() {
    super.initState();
    _loadConversation();
    _apiServiceProvider =
        Provider.of<ApiServiceProvider>(context, listen: false);
    _webSocketService = Provider.of<WebSocketService>(context, listen: false);
    _ensureWebSocketConnection();
    _listenToMessages();
    _webSocketService.registerUpdateCallback(_updateUIWithNewMessage);
  }

  Future<void> _ensureWebSocketConnection() async {
    if (!_webSocketService.isConnected) {
      String? token = await _apiServiceProvider.getToken();
      if (token != null) {
        await _webSocketService.connect(token);
      } else {
        log('Error: Token is null');
      }
    }
  }

  // void _listenToMessages() {
  //   final webSocketService =
  //       Provider.of<WebSocketService>(context, listen: false);
  //   _messageSubscription = webSocketService.messageStream.listen((newMessage) {
  //     if (newMessage.recipientId == widget.selectedConversation.recipientId ||
  //         newMessage.senderId == widget.selectedConversation.recipientId) {
  //       setState(() {
  //         _messages.add(newMessage);
  //       });
  //     }
  //   });
  // }

  void _listenToMessages() {
    _messageSubscription = _webSocketService.messageStream.listen((newMessage) {
      if (newMessage.recipientId == widget.selectedConversation.recipientId ||
          newMessage.senderId == widget.selectedConversation.recipientId) {
        _updateUIWithNewMessage(newMessage);
      }
    });
  }

  void _updateUIWithNewMessage(Conversation newMessage) {
    if (mounted) {
      setState(() {
        _messages.add(newMessage);
      });
    }
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
      log('Error loading conversation: $e');
    }
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      final newMessage = Conversation(
        id: widget.selectedConversation.id, // Temporary ID
        senderId: widget.currentUserId,
        recipientId: widget.selectedConversation.senderId,
        content: _messageController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        senderUsername: widget.selectedConversation.senderUsername,
        recipientUsername: widget.selectedConversation.recipientUsername,
      );

      setState(() {
        _messages.add(newMessage);
      });

      _webSocketService.sendMessage(
          widget.selectedConversation.senderId, _messageController.text);
      _messageController.clear();
    }
  }

  String _getAvatarText(String username) {
    return username.isNotEmpty ? username[0].toUpperCase() : '?';
  }

  String _formatTimestamp(DateTime timestamp) {
    return DateFormat('HH:mm').format(timestamp);
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final avatarText =
        _getAvatarText(widget.selectedConversation.recipientUsername);
    final capitalizedUsername =
        _capitalizeFirstLetter(widget.selectedConversation.recipientUsername);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 24.0),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Text(
                avatarText,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            Text(capitalizedUsername),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              child: const Icon(Icons.more_horiz),
              onTap: () {},
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              reverse: true, // This will make the list start from the bottom
              itemBuilder: (context, index) {
                final conversation = _messages[_messages.length - 1 - index];
                final isFromSender =
                    conversation.senderId == widget.currentUserId;
                return ChatBubble(
                  message: conversation.content,
                  isFromSender: isFromSender,
                  timestamp: _formatTimestamp(conversation.createdAt),
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
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    onSubmitted: (text) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  backgroundColor: Colors.blueAccent,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.send),
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
    _messageSubscription.cancel();
    _webSocketService.unregisterUpdateCallback(_updateUIWithNewMessage);
    super.dispose();
  }
}


// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'package:chat/model/conversation.dart';
// import 'package:chat/provider/api_service_provider.dart';
// import 'package:chat/reusable_widgets/chat_bubble.dart';
// import 'package:chat/services/websocket_service.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';

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
//   late ApiServiceProvider _apiServiceProvider;
//   List<Conversation> _messages = [];
//   late StreamSubscription<Conversation> _messageSubscription;

//   @override
//   void initState() {
//     super.initState();
//     _loadConversation();
//     _apiServiceProvider =
//         Provider.of<ApiServiceProvider>(context, listen: false);
//     _webSocketService = Provider.of<WebSocketService>(context, listen: false);
//     _ensureWebSocketConnection();
//     _listenToMessages();
//   }

//   Future<void> _ensureWebSocketConnection() async {
//     if (!_webSocketService.isConnected) {
//       String? token = await _apiServiceProvider.getToken();
//       if (token != null) {
//         await _webSocketService.connect(token);
//       } else {
//         log('Error: Token is null');
//       }
//     }
//   }

//   void _listenToMessages() {
//     final webSocketService =
//         Provider.of<WebSocketService>(context, listen: false);
//     _messageSubscription = webSocketService.messageStream.listen((newMessage) {
//       if (newMessage.recipientId == widget.selectedConversation.recipientId ||
//           newMessage.senderId == widget.selectedConversation.recipientId) {
//         setState(() {
//           _messages.add(newMessage);
//         });
//       }
//     });
//   }
  

//   Future<void> _loadConversation() async {
//     final apiServiceProvider =
//         Provider.of<ApiServiceProvider>(context, listen: false);
//     try {
//       final conversationsResponse = await apiServiceProvider
//           .getAllConversations(widget.selectedConversation.senderId);
//       final conversations =
//           (jsonDecode(conversationsResponse.body)['data'] as List<dynamic>)
//               .map((conversation) =>
//                   Conversation.fromMap(conversation as Map<String, dynamic>))
//               .toList();

//       setState(() {
//         _messages = conversations;
//       });
//     } catch (e) {
//       log('Error loading conversation: $e');
//     }
//   }

//   void _sendMessage() {
//     if (_messageController.text.isNotEmpty) {
//       final newMessage = Conversation(
//         id: widget.selectedConversation.id, // Temporary ID
//         senderId: widget.currentUserId,
//         recipientId: widget.selectedConversation.senderId,
//         content: _messageController.text,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//         senderUsername: widget.selectedConversation
//             .senderUsername, 
//         recipientUsername: widget.selectedConversation.recipientUsername,
//       );

//       setState(() {
//         _messages.add(newMessage);
//       });

//       _webSocketService.sendMessage(
//           widget.selectedConversation.senderId, _messageController.text);
//       _messageController.clear();
//     }
//   }

//   String _getAvatarText(String username) {
//     return username.isNotEmpty ? username[0].toUpperCase() : '?';
//   }

//   String _formatTimestamp(DateTime timestamp) {
//     return DateFormat('HH:mm').format(timestamp);
//   }

//   String _capitalizeFirstLetter(String text) {
//     if (text.isEmpty) return text;
//     return text[0].toUpperCase() + text.substring(1);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final avatarText =
//         _getAvatarText(widget.selectedConversation.recipientUsername);
//     final capitalizedUsername =
//         _capitalizeFirstLetter(widget.selectedConversation.recipientUsername);

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, size: 24.0),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Row(
//           children: [
//             CircleAvatar(
//               backgroundColor: Colors.blueAccent,
//               child: Text(
//                 avatarText,
//                 style: const TextStyle(color: Colors.white),
//               ),
//             ),
//             const SizedBox(width: 10),
//             Text(capitalizedUsername),
//           ],
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: InkWell(
//               child: const Icon(Icons.more_horiz),
//               onTap: () {},
//             ),
//           )
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: _messages.length,
//               reverse: true, // This will make the list start from the bottom
//               itemBuilder: (context, index) {
//                 final conversation = _messages[_messages.length - 1 - index];
//                 final isFromSender =
//                     conversation.senderId == widget.currentUserId;
//                 return ChatBubble(
//                   message: conversation.content,
//                   isFromSender: isFromSender,
//                   timestamp: _formatTimestamp(conversation.createdAt),
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
//                     decoration: InputDecoration(
//                       hintText: 'Type a message...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(30.0),
//                         borderSide: BorderSide.none,
//                       ),
//                       filled: true,
//                       fillColor: Colors.grey[200],
//                       contentPadding:
//                           const EdgeInsets.symmetric(horizontal: 16.0),
//                     ),
//                     onSubmitted: (text) => _sendMessage(),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 FloatingActionButton(
//                   onPressed: _sendMessage,
//                   backgroundColor: Colors.blueAccent,
//                   shape: const CircleBorder(),
//                   child: const Icon(Icons.send),
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
//     _messageSubscription.cancel();
//     super.dispose();
//   }
// }