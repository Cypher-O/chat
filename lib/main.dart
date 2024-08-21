import 'package:chat/provider/api_service_provider.dart';
import 'package:chat/screens/chat_screen.dart';
import 'package:chat/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat/screens/login_screen.dart';
import 'package:chat/services/websocket_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ApiServiceProvider()),
        ChangeNotifierProvider(create: (_) => WebSocketService()),
      ],
      child: MaterialApp(
        home: const LoginScreen(),
        routes: {
          '/register': (context) => const RegisterScreen(),
          '/chat': (context) => const ChatScreen(),
        },
      ),
    );
  }
}