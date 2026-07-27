

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/services/firestore_service.dart';
import 'package:chatapp/models/chat_model.dart';

class HomeController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final RxList<ChatModel> chats = <ChatModel>[].obs;
  final RxBool isLoading = true.obs;

  String get currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    _listenToChats();
  }

  void _listenToChats() {
    if (currentUid.isEmpty) return;
    _firestoreService.watchUserChats(currentUid).listen((chatList) {
      chats.value = chatList;
      isLoading.value = false;
    });
  }

  /// Starts (or opens) a 1:1 chat with another user and returns the chatId.
  Future<String> openChatWith(String otherUid) {
    return _firestoreService.getOrCreateChat(currentUid, otherUid);
  }
}