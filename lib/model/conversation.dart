class Conversation {
  final String id;
  final String senderId;
  final String recipientId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String senderUsername;
  final String recipientUsername;

  Conversation({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.senderUsername,
    required this.recipientUsername,
  });

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] ?? '',
      senderId: map['sender_id'] ?? '',
      recipientId: map['recipient_id'] ?? '',
      content: map['content'] ?? '',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
      senderUsername: map['sender_username'] ?? '',
      recipientUsername: map['recipient_username'] ?? '',
    );
  }

   Conversation copyWith({
    String? id,
    String? senderId,
    String? recipientId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? senderUsername,
    String? recipientUsername,
  }) {
    return Conversation(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      recipientId: recipientId ?? this.recipientId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      senderUsername: senderUsername ?? this.senderUsername,
      recipientUsername: recipientUsername ?? this.recipientUsername,
    );
  }
}
