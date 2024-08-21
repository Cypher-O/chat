import 'dart:convert';
import 'package:chat/model/conversation.dart';
import 'package:chat/provider/api_service_provider.dart';
import 'package:chat/screens/chat_screen.dart';
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
    _loadRecentConversations();
  }

  Future<void> _loadRecentConversations() async {
    final apiServiceProvider =
        Provider.of<ApiServiceProvider>(context, listen: false);
    try {
      final userResponse = await apiServiceProvider.getUserData();
      final userData = jsonDecode(userResponse.body);

      _userId = userData['data']['id']?.toString() ?? '';
      if (_userId.isNotEmpty) {
        final recentConversationsResponse =
            await apiServiceProvider.getRecentConversations();
        final recentConversations =
            (jsonDecode(recentConversationsResponse.body)['data']
                    as List<dynamic>)
                .map((conversation) =>
                    Conversation.fromMap(conversation as Map<String, dynamic>))
                .toList();

        setState(() {
          _recentConversations = recentConversations;
        });
      } else {
        debugPrint('Error: userId is null or empty');
      }
    } catch (e) {
      debugPrint('Error loading recent conversations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView.builder(
        itemCount: _recentConversations.length,
        itemBuilder: (context, index) {
          final conversation = _recentConversations[index];
          return ListTile(
            title: Text(conversation.senderUsername),
            subtitle: Text(conversation.content),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/chat',
                arguments: {
                  'selectedConversation': conversation,
                  'currentUserId': _userId,
                },
              );

              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => ChatScreen(
              //       selectedConversation: conversation,
              //       currentUserId: _userId,
              //     ),
              //   ),
              // );
            },
          );
        },
      ),
    );
  }
}
