class ChatMessage {
  final String id;
  final String role; // 'user' or 'bot'
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory ChatMessage.user(String id, String content) => ChatMessage(
        id: id,
        role: 'user',
        content: content,
        timestamp: DateTime.now(),
      );

  factory ChatMessage.bot(String id, String content) => ChatMessage(
        id: id,
        role: 'bot',
        content: content,
        timestamp: DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };

  static ChatMessage fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        role: json['role'] as String,
        content: json['content'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}