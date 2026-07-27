


enum CallType { voice, video }

class CallModel {
  final String id;
  final String callerId;
  final String callerName;
  final String receiverId;
  final String receiverName;
  final CallType type;
  final DateTime calledAt;

  CallModel({
    required this.id,
    required this.callerId,
    required this.callerName,
    required this.receiverId,
    required this.receiverName,
    required this.type,
    required this.calledAt,
  });

  factory CallModel.fromMap(Map<String, dynamic> map, String id) {
    return CallModel(
      id: id,
      callerId: map['callerId'] ?? '',
      callerName: map['callerName'] ?? '',
      receiverId: map['receiverId'] ?? '',
      receiverName: map['receiverName'] ?? '',
      type: CallType.values.firstWhere(
        (e) => e.name == (map['type'] ?? 'voice'),
        orElse: () => CallType.voice,
      ),
      calledAt: map['calledAt'] != null
          ? DateTime.tryParse(map['calledAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'callerId': callerId,
      'callerName': callerName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'type': type.name,
      'calledAt': calledAt.toIso8601String(),
    };
  }
}