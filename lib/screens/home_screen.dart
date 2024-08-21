// import 'dart:convert';
// import 'package:chat/model/conversation.dart';
// import 'package:chat/provider/api_service_provider.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   HomeScreenState createState() => HomeScreenState();
// }

// class HomeScreenState extends State<HomeScreen> {
//   List<Conversation> _recentConversations = [];
//   String _userId = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadRecentConversations();
//   }

//   Future<void> _loadRecentConversations() async {
//     final apiServiceProvider =
//         Provider.of<ApiServiceProvider>(context, listen: false);
//     try {
//       final userResponse = await apiServiceProvider.getUserData();
//       final userData = jsonDecode(userResponse.body);

//       _userId = userData['data']['id']?.toString() ?? '';
//       if (_userId.isNotEmpty) {
//         final recentConversationsResponse =
//             await apiServiceProvider.getRecentConversations();
//         final recentConversations =
//             (jsonDecode(recentConversationsResponse.body)['data']
//                     as List<dynamic>)
//                 .map((conversation) =>
//                     Conversation.fromMap(conversation as Map<String, dynamic>))
//                 .toList();

//         setState(() {
//           _recentConversations = recentConversations;
//         });
//       } else {
//         debugPrint('Error: userId is null or empty');
//       }
//     } catch (e) {
//       debugPrint('Error loading recent conversations: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Home')),
//       body: ListView.builder(
//         itemCount: _recentConversations.length,
//         itemBuilder: (context, index) {
//           final conversation = _recentConversations[index];
//           return ListTile(
//             title: Text(conversation.senderUsername),
//             subtitle: Text(conversation.content),
//             onTap: () {
//               Navigator.pushNamed(
//                 context,
//                 '/chat',
//                 arguments: {
//                   'selectedConversation': conversation,
//                   'currentUserId': _userId,
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }



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
  String _firstName = '';
  String _lastName = '';

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
      _firstName = userData['data']['firstName'] ?? '';
      _lastName = userData['data']['lastName'] ?? '';
      
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
      final recentConversations =
          (jsonDecode(recentConversationsResponse.body)['data']
                  as List<dynamic>)
              .map((conversation) =>
                  Conversation.fromMap(conversation as Map<String, dynamic>))
              .toList();

      setState(() {
        _recentConversations = recentConversations;
      });
    } catch (e) {
      debugPrint('Error loading recent conversations: $e');
    }
  }

  String _getAvatarText(String username) {
    if (username == null || username.isEmpty) {
      return 'NN'; // Default to 'NN' for unknown names
    }

    final names = username.split(' ');

    final firstLetter = names.isNotEmpty && names[0].isNotEmpty ? names[0][0] : 'N';
    final lastLetter = names.length > 1 && names[1].isNotEmpty ? names[1][0] : 'N';

    return '$firstLetter$lastLetter'.toUpperCase();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: ListView.builder(
        itemCount: _recentConversations.length,
        itemBuilder: (context, index) {
          final conversation = _recentConversations[index];
          final avatarText = _getAvatarText(conversation.senderUsername);
          final updatedAt = _formatTimestamp(conversation.updatedAt);

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Text(avatarText, style: const TextStyle(color: Colors.white)),
            ),
            title: Text(conversation.senderUsername),
            subtitle: Text(conversation.content),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(updatedAt, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
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
