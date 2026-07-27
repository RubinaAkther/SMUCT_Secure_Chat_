

enum MessageType { text, image, video, audio, file }

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final MessageType type;
  final DateTime sentAt;
  final bool isSeen;
  final String? mediaUrl;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    this.type = MessageType.text,
    required this.sentAt,
    this.isSeen = false,
    this.mediaUrl,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'text'),
        orElse: () => MessageType.text,
      ),
      sentAt: map['sentAt'] != null
          ? DateTime.tryParse(map['sentAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isSeen: map['isSeen'] ?? false,
      mediaUrl: map['mediaUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'type': type.name,
      'sentAt': sentAt.toIso8601String(),
      'isSeen': isSeen,
      'mediaUrl': mediaUrl,
    };
  }
}