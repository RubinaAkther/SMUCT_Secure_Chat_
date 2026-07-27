


import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chatapp/services/firestore_service.dart';
import 'package:chatapp/models/message_model.dart';

class ChatController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final String chatId;

  ChatController({required this.chatId});

  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isUploadingImage = false.obs;

  String get currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    _listenToMessages();
  }

  void _listenToMessages() {
    _firestoreService.watchMessages(chatId).listen((msgList) {
      messages.value = msgList;
      isLoading.value = false;
    });
  }

  Future<void> sendTextMessage(String text) async {
    if (text.trim().isEmpty) return;

    final message = MessageModel(
      id: '', // Firestore auto-generates the doc id
      senderId: currentUid,
      text: text.trim(),
      sentAt: DateTime.now(),
    );

    await _firestoreService.sendMessage(chatId, message);
  }

  Future<void> sendImageMessage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked == null) return;

    try {
      isUploadingImage.value = true;

      final Uint8List bytes = await picked.readAsBytes();

      final imageUrl = await _firestoreService.uploadChatImage(
        chatId,
        bytes,
        picked.name,
      );

      final message = MessageModel(
        id: '',
        senderId: currentUid,
        text: '📷 Photo',
        type: MessageType.image,
        sentAt: DateTime.now(),
        mediaUrl: imageUrl,
      );

      await _firestoreService.sendMessage(chatId, message);
    } finally {
      isUploadingImage.value = false;
    }
  }
}