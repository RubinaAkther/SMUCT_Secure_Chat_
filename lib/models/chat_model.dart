

class ChatModel {
  final String chatId;
  final List<String> participantIds;
  final String lastMessage;
  final DateTime lastMessageAt;
  final String lastSenderId;
  final Map<String, int> unreadCount; // uid -> unread count

  ChatModel({
    required this.chatId,
    required this.participantIds,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.lastSenderId,
    this.unreadCount = const {},
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, String chatId) {
    return ChatModel(
      chatId: chatId,
      participantIds: List<String>.from(map['participantIds'] ?? []),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageAt: map['lastMessageAt'] != null
          ? DateTime.tryParse(map['lastMessageAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      lastSenderId: map['lastSenderId'] ?? '',
      unreadCount: Map<String, int>.from(map['unreadCount'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'lastSenderId': lastSenderId,
      'unreadCount': unreadCount,
    };
  }
}