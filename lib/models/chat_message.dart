
class ChatMessage {
  final String id;
  final MessageType type;
  final String content;
  final DateTime timestamp;
  final bool isTyping;

  ChatMessage({
    required this.id,
    required this.type,
    required this.content,
    required this.timestamp,
    this.isTyping = false,
  });
}

enum MessageType { bot, user }
