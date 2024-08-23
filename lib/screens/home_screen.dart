import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:chat/model/conversation.dart';
import 'package:chat/provider/api_service_provider.dart';
import 'package:chat/services/websocket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  List<Conversation> _recentConversations = [];
  String _userId = '';
  late WebSocketService _webSocketService;
  late ApiServiceProvider _apiServiceProvider;
  late StreamSubscription<Conversation> _messageSubscription;

  @override
  void initState() {
    super.initState();
    log('Initializing HomeScreen');
    _loadUserData();
    _apiServiceProvider =
        Provider.of<ApiServiceProvider>(context, listen: false);
    _webSocketService = Provider.of<WebSocketService>(context, listen: false);
    _ensureWebSocketConnection();
    _webSocketService.addListener(_handleWebSocketStateChange);
    _webSocketService.registerUpdateCallback(updateConversations);

    // Subscribe to WebSocket messages
    _messageSubscription = _webSocketService.messageStream.listen((newMessage) {
      log('Received message from WebSocket: ${newMessage.content}');
      updateConversations(newMessage);
    });
  }

  void _handleWebSocketStateChange() {
    if (!_webSocketService.isConnected) {
      _ensureWebSocketConnection();
    }
  }

  void updateConversations(Conversation newMessage) {
    setState(() {
      final index = _recentConversations.indexWhere((conversations) =>
          (conversations.senderId == newMessage.senderId && conversations.recipientId == newMessage.recipientId) ||
          (conversations.senderId == newMessage.recipientId && conversations.recipientId == newMessage.senderId));

      if (index >= 0) {
        _recentConversations[index] = _recentConversations[index].copyWith(
          content: newMessage.content,
          updatedAt: newMessage.createdAt,
        );
      } else {
        _recentConversations.add(newMessage);
      }

      _recentConversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    });
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _ensureWebSocketConnection() async {
    if (!_webSocketService.isConnected) {
      String? token = await _apiServiceProvider.getToken();
      if (token != null) {
        await _webSocketService.connect(token);
        log('WebSocket connected successfully');
      } else {
        log('Error: Token is null');
      }
    }
  }

  @override
  void dispose() {
    _webSocketService.unregisterUpdateCallback(updateConversations);
    _webSocketService.removeListener(_handleWebSocketStateChange);
    _messageSubscription.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final apiServiceProvider =
        Provider.of<ApiServiceProvider>(context, listen: false);
    try {
      final userResponse = await apiServiceProvider.getUserData();
      final userData = jsonDecode(userResponse.body);

      _userId = userData['data']['id']?.toString() ?? '';

      if (_userId.isNotEmpty) {
        await _loadRecentConversations();
      } else {
        log('Error: userId is null or empty');
      }
    } catch (e) {
      log('Error loading user data: $e');
    }
  }

  Future<void> _loadRecentConversations() async {
    final apiServiceProvider =
        Provider.of<ApiServiceProvider>(context, listen: false);
    try {
      final recentConversationsResponse =
          await apiServiceProvider.getRecentConversations();
      final responseData = jsonDecode(recentConversationsResponse.body);

      if (responseData['status'] == 'success' && responseData['data'] is List) {
        final recentConversations =
            (responseData['data'] as List).map((conversation) {
          return Conversation(
              id: conversation['id'],
              senderId: conversation['sender_id'],
              recipientId: conversation['recipient_id'],
              content: conversation['content'],
              createdAt: DateTime.parse(conversation['created_at']),
              updatedAt: DateTime.parse(conversation['updated_at']),
              recipientUsername: conversation['other_user_username'],
              senderUsername: conversation['other_user_id']);
        }).toList();

        setState(() {
          _recentConversations = recentConversations;
        });
      } else {
        log('Error: Invalid response format');
      }
    } catch (e) {
      log('Error loading recent conversations: $e');
    }
  }

  String _getAvatarText(String recipientUsername) {
    if (recipientUsername.isEmpty) {
      return '?';
    }
    return recipientUsername[0].toUpperCase();
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView.builder(
        key: ValueKey<int>(_recentConversations.length), // Add this line
        itemCount: _recentConversations.length,
        itemBuilder: (context, index) {
          final conversation = _recentConversations[index];
          final avatarText = _getAvatarText(conversation.recipientUsername);
          final formattedUsername =
              _capitalizeFirstLetter(conversation.recipientUsername);
          final updatedAt = _formatTimestamp(conversation.updatedAt);

          return ListTile(
            key: ValueKey<String>(conversation.id), // Add this line
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child:
                  Text(avatarText, style: const TextStyle(color: Colors.white)),
            ),
            title: Text(formattedUsername),
            subtitle: Text(conversation.content),
            trailing:
                Text(updatedAt, style: TextStyle(color: Colors.grey[600])),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/chat',
                arguments: {
                  'selectedConversation': conversation,
                  'currentUserId': _userId,
                },
              );
            },
          );
        },
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: const Text('Home')),
  //     body: ListView.builder(
  //       itemCount: _recentConversations.length,
  //       itemBuilder: (context, index) {
  //         final conversation = _recentConversations[index];
  //         final avatarText = _getAvatarText(conversation.recipientUsername);
  //         final formattedUsername =
  //             _capitalizeFirstLetter(conversation.recipientUsername);
  //         final updatedAt = _formatTimestamp(conversation.updatedAt);

  //         return ListTile(
  //           leading: CircleAvatar(
  //             backgroundColor: Colors.blueAccent,
  //             child:
  //                 Text(avatarText, style: const TextStyle(color: Colors.white)),
  //           ),
  //           title: Text(formattedUsername),
  //           subtitle: Text(conversation.content),
  //           trailing:
  //               Text(updatedAt, style: TextStyle(color: Colors.grey[600])),
  //           onTap: () {
  //             Navigator.pushNamed(
  //               context,
  //               '/chat',
  //               arguments: {
  //                 'selectedConversation': conversation,
  //                 'currentUserId': _userId,
  //               },
  //             );
  //           },
  //         );
  //       },
  //     ),
  //   );
  // }
}
