import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isFromSender;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isFromSender,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isFromSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isFromSender ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Text(
          message,
          style: TextStyle(
            color: isFromSender ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
