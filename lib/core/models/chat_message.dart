class ChatMessage {
  final String id;
  final String sessionId;
  final MessageContent message;
  final DateTime time;

  ChatMessage({
    required this.id,
    required this.sessionId,
    required this.message,
    required this.time,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // Support alternate timestamp column names commonly used in tenant schemas
    final dynamic timeRaw = json['time'] ?? json['created_at'] ?? json['timestamp'] ?? json['createdAt'];
    DateTime parsedTime;
    if (timeRaw is String) {
      parsedTime = DateTime.parse(timeRaw);
    } else if (timeRaw is int) {
      parsedTime = DateTime.fromMillisecondsSinceEpoch(timeRaw, isUtc: true);
    } else {
      parsedTime = DateTime.now();
    }

    // Build MessageContent from various possible shapes
    final dynamic rawMessage = json['message'] ?? json['content'] ?? json['text'] ?? '';
    final String derivedType = _deriveType(json);
    final MessageContent messageContent = _toMessageContent(rawMessage, derivedType);

    return ChatMessage(
      id: (json['id'] ?? '').toString(),
      sessionId: (json['session_id'] ?? json['sessionId'] ?? '').toString(),
      message: messageContent,
      time: parsedTime,
    );
  }

  static String _deriveType(Map<String, dynamic> json) {
    final String role = (json['role'] ?? json['sender'] ?? json['message_type'] ?? '').toString().toLowerCase();
    final bool? isAIFlag = json['is_ai'] as bool?;
    if (isAIFlag != null) {
      return isAIFlag ? 'ai' : 'human';
    }
    if (role == 'ai' || role == 'assistant' || role == 'bot') return 'ai';
    if (role == 'human' || role == 'user' || role == 'customer') return 'human';
    return 'ai';
  }

  static MessageContent _toMessageContent(dynamic raw, String derivedType) {
    if (raw is Map<String, dynamic>) {
      // If map, prefer existing keys; fallback to derived type/content
      final String type = (raw['type'] ?? derivedType).toString();
      final String content = (raw['content'] ?? raw['text'] ?? '').toString();
      final Map<String, dynamic> additional = raw['additional_kwargs'] as Map<String, dynamic>? ?? {};
      final Map<String, dynamic> meta = raw['response_metadata'] as Map<String, dynamic>? ?? {};
      return MessageContent(
        type: type,
        content: content,
        additionalKwargs: additional,
        responseMetadata: meta,
      );
    }
    // If string or other primitive, wrap into content with derived type
    final String content = raw?.toString() ?? '';
    return MessageContent(
      type: derivedType,
      content: content,
      additionalKwargs: const {},
      responseMetadata: const {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'message': message.toJson(),
      'time': time.toIso8601String(),
    };
  }
}

class MessageContent {
  final String type; // 'human' or 'ai'
  final String content;
  final Map<String, dynamic> additionalKwargs;
  final Map<String, dynamic> responseMetadata;

  MessageContent({
    required this.type,
    required this.content,
    required this.additionalKwargs,
    required this.responseMetadata,
  });

  factory MessageContent.fromJson(Map<String, dynamic> json) {
    return MessageContent(
      type: json['type'] as String,
      content: json['content'] as String,
      additionalKwargs: json['additional_kwargs'] as Map<String, dynamic>? ?? {},
      responseMetadata: json['response_metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'content': content,
      'additional_kwargs': additionalKwargs,
      'response_metadata': responseMetadata,
    };
  }
  
  bool get isHuman => type == 'human';
  bool get isAI => type == 'ai' || type == 'assistant';
}

