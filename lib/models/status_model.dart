

enum StatusType { text, image }

class StatusModel {
  final String id;
  final String uid;
  final String userName;
  final StatusType type;
  final String? text;
  final String? imageUrl;
  final DateTime createdAt;

  StatusModel({
    required this.id,
    required this.uid,
    required this.userName,
    required this.type,
    this.text,
    this.imageUrl,
    required this.createdAt,
  });

  factory StatusModel.fromMap(Map<String, dynamic> map, String id) {
    return StatusModel(
      id: id,
      uid: map['uid'] ?? '',
      userName: map['userName'] ?? '',
      type: StatusType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'text'),
        orElse: () => StatusType.text,
      ),
      text: map['text'],
      imageUrl: map['imageUrl'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'userName': userName,
      'type': type.name,
      'text': text,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}