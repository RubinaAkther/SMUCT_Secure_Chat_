import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/models/message_model.dart';
import 'package:chatapp/models/chat_model.dart';
import 'package:chatapp/models/status_model.dart';
import 'package:chatapp/models/call_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ---------- Cloudinary config ----------
  static const String _cloudName = 'sjuohl5h';
  static const String _uploadPreset = 'chatapp_images';

  // ---------- Users ----------
  Future<void> createOrUpdateUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(
          user.toMap(),
          SetOptions(merge: true),
        );
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  /// Fetches all users except [currentUid] — used by the "New Chat" contact picker.
  Future<List<UserModel>> getAllUsersExcept(String currentUid) async {
    final snap = await _db.collection('users').get();
    return snap.docs
        .where((doc) => doc.id != currentUid)
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<UserModel?> watchUser(String uid) {
    return _db.collection('users').doc(uid).snapshots().map(
          (doc) => doc.exists ? UserModel.fromMap(doc.data()!, doc.id) : null,
        );
  }

  // ---------- Chats (list on Home screen) ----------
  Stream<List<ChatModel>> watchUserChats(String uid) {
    return _db
        .collection('chats')
        .where('participantIds', arrayContains: uid)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ChatModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// Creates a 1:1 chat if it doesn't already exist; returns chatId.
  Future<String> getOrCreateChat(String uidA, String uidB) async {
    final ids = [uidA, uidB]..sort();
    final chatId = ids.join('_');

    final docRef = _db.collection('chats').doc(chatId);
    final doc = await docRef.get();
    if (!doc.exists) {
      await docRef.set({
        'participantIds': ids,
        'lastMessage': '',
        'lastMessageAt': DateTime.now().toIso8601String(),
        'lastSenderId': '',
        'unreadCount': {uidA: 0, uidB: 0},
      });
    }
    return chatId;
  }

  // ---------- Messages ----------
  Stream<List<MessageModel>> watchMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> sendMessage(String chatId, MessageModel message) async {
    final chatRef = _db.collection('chats').doc(chatId);

    await chatRef.collection('messages').add(message.toMap());

    await chatRef.update({
      'lastMessage': message.text,
      'lastMessageAt': message.sentAt.toIso8601String(),
      'lastSenderId': message.senderId,
    });
  }

  // ---------- Image Upload (Cloudinary, free, no billing needed) ----------
  Future<String> uploadChatImage(
    String folderKey,
    Uint8List bytes,
    String fileName,
  ) async {
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = 'chat_images/$folderKey'
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
        ),
      );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      throw Exception('Image upload failed: ${response.body}');
    }

    final data = jsonDecode(response.body);
    return data['secure_url'] as String;
  }

  // ---------- Status ----------
  Stream<List<StatusModel>> watchAllStatuses() {
    return _db
        .collection('statuses')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => StatusModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> postStatus(StatusModel status) async {
    await _db.collection('statuses').add(status.toMap());
  }

  // ---------- Calls ----------
  Stream<List<CallModel>> watchUserCalls(String uid) {
    return _db
        .collection('calls')
        .where('participants', arrayContains: uid)
        .orderBy('calledAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => CallModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> logCall(CallModel call) async {
    final map = call.toMap();
    map['participants'] = [call.callerId, call.receiverId];
    await _db.collection('calls').add(map);
  }
}