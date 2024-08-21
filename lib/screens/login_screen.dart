import 'dart:convert';
import 'package:chat/provider/api_service_provider.dart';
import 'package:chat/screens/register_screen.dart';
import 'package:chat/services/websocket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // void _login() async {
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   final apiServiceProvider = Provider.of<ApiServiceProvider>(context, listen: false);
  //   final webSocketService = Provider.of<WebSocketService>(context, listen: false);

  //   final response = await apiServiceProvider.loginUser({
  //     'username': _usernameController.text,
  //     'password': _passwordController.text,
  //   });

  //   if (response.statusCode == 200) {
  //     final responseData = jsonDecode(response.body);
  //     final token = responseData['data']['token'];
  //     await webSocketService.connect(token);

  //     try {
  //       final userResponse = await apiServiceProvider.getUserData();
  //       final userData = jsonDecode(userResponse.body);
  //       final userId = int.parse(userData['data']['id']);

  //       // Fetch recent conversations
  //       final recentConversationsResponse = await apiServiceProvider.getRecentConversations();
  //       debugPrint('Recent conversations: ${recentConversationsResponse.body}');

  //       // Fetch conversation history
  //       final conversationsResponse = await apiServiceProvider.getAllConversations(userId);
  //       debugPrint('Conversation history: ${conversationsResponse.body}');

  //       setState(() {
  //         _isLoading = false;
  //       });
  //       Navigator.pushNamed(context, '/chat');
  //     } catch (e) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //       // Handle error
  //       debugPrint('Error getting user data: $e');
  //     }
  //   } else {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //     // Handle error
  //   }
  void _login() async {
    setState(() {
      _isLoading = true;
    });

    final apiServiceProvider = Provider.of<ApiServiceProvider>(context, listen: false);
    final webSocketService = Provider.of<WebSocketService>(context, listen: false);

    final response = await apiServiceProvider.loginUser({
      'username': _usernameController.text,
      'password': _passwordController.text,
    });

    if (response.statusCode == 200) {
      try {
        final responseData = jsonDecode(response.body);
      final token = responseData['data']['token'];
      await webSocketService.connect(token);

        final userResponse = await apiServiceProvider.getUserData();
        final userData = jsonDecode(userResponse.body);
        final userId = userData['data']['id'];

        // Fetch recent conversations
        final recentConversationsResponse = await apiServiceProvider.getRecentConversations();
        debugPrint('Recent conversations: ${recentConversationsResponse.body}');

        // Fetch conversation history
        final conversationsResponse = await apiServiceProvider.getAllConversations(userId);
        debugPrint('Conversation history: ${conversationsResponse.body}');

        setState(() {
          _isLoading = false;
        });
        Navigator.pushNamed(context, '/chat');
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        debugPrint('Error getting user data: $e');
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                  ),
                  ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text('Don\'t have an account? Register here'),
                  ),
                ],
              ),
            ),
    );
  }
}


// class LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   void _login() async {
//     final apiServiceProvider = Provider.of<ApiServiceProvider>(context, listen: false);
//     final webSocketService = Provider.of<WebSocketService>(context, listen: false);

//     final response = await apiServiceProvider.loginUser({
//       'username': _usernameController.text,
//       'password': _passwordController.text,
//     });
    
//     if (response.statusCode == 200) {
//       final responseData = jsonDecode(response.body);
//       final token = responseData['data']['token'];
//       await webSocketService.connect(token);

//       // Get the user's ID
//       final userResponse = await apiServiceProvider.getUserData();
//       final userData = jsonDecode(userResponse.body);
//       final userId = int.parse(userData['data']['id']);

//       // Fetch recent conversations
//       final recentConversationsResponse = await apiServiceProvider.getRecentConversations();
//       debugPrint('Recent conversations: ${recentConversationsResponse.body}');

//       // Fetch conversation history
//       final conversationsResponse = await apiServiceProvider.getAllConversations(userId);
//       debugPrint('Conversation history: ${conversationsResponse.body}');

//       Navigator.pushNamed(context, '/chat');
//     } else {
//       // Handle error
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _usernameController,
//               decoration: const InputDecoration(labelText: 'Username'),
//             ),
//             TextField(
//               controller: _passwordController,
//               decoration: const InputDecoration(labelText: 'Password'),
//               obscureText: true,
//             ),
//             ElevatedButton(
//               onPressed: _login,
//               child: const Text('Login'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const RegisterScreen()),
//                 );
//               },
//               child: const Text('Don\'t have an account? Register here'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
