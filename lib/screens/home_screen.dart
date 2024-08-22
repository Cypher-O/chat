import 'dart:convert';
import 'package:chat/model/conversation.dart';
import 'package:chat/provider/api_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Conversation> _recentConversations = [];
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
        debugPrint('Error: userId is null or empty');
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
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
        debugPrint('Error: Invalid response format');
      }
    } catch (e) {
      debugPrint('Error loading recent conversations: $e');
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
        itemCount: _recentConversations.length,
        itemBuilder: (context, index) {
          final conversation = _recentConversations[index];
          final avatarText = _getAvatarText(conversation.recipientUsername);
          final formattedUsername =
              _capitalizeFirstLetter(conversation.recipientUsername);
          final updatedAt = _formatTimestamp(conversation.updatedAt);

          return ListTile(
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
}
