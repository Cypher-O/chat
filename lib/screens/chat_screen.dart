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

  @override
  void initState() {
    super.initState();
    _webSocketService = Provider.of<WebSocketService>(context, listen: false);
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
            child: StreamBuilder(
              stream: _webSocketService.messages,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    children: [
                      ListTile(title: Text(snapshot.data.toString())),
                    ],
                  );
                } else {
                  return const Center(child: Text('No messages'));
                }
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
