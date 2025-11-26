import 'chat_message.dart';

class Session {
  final String sessionId; // phone number
  final List<ChatMessage> messages;
  final DateTime? lastMessageTime;

  Session({
    required this.sessionId,
    required this.messages,
    this.lastMessageTime,
  });

  DateTime get lastMessageDateTime {
    if (lastMessageTime != null) return lastMessageTime!;
    if (messages.isEmpty) return DateTime.now();
    return messages.map((m) => m.time).reduce((a, b) => a.isAfter(b) ? a : b);
  }

  ChatMessage? get lastMessage {
    if (messages.isEmpty) return null;
    return messages.reduce((a, b) => a.time.isAfter(b.time) ? a : b);
  }
}

