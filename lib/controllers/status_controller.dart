

import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chatapp/services/firestore_service.dart';
import 'package:chatapp/models/status_model.dart';

class StatusController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final RxList<StatusModel> statuses = <StatusModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isPosting = false.obs;

  String get currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    _listenToStatuses();
  }

  void _listenToStatuses() {
    _firestoreService.watchAllStatuses().listen((list) {
      statuses.value = list;
      isLoading.value = false;
    });
  }

  Future<void> postTextStatus(String text, String userName) async {
    if (text.trim().isEmpty) return;

    final status = StatusModel(
      id: '',
      uid: currentUid,
      userName: userName,
      type: StatusType.text,
      text: text.trim(),
      createdAt: DateTime.now(),
    );

    await _firestoreService.postStatus(status);
  }

  Future<void> postImageStatus(String userName) async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked == null) return;

    try {
      isPosting.value = true;
      final Uint8List bytes = await picked.readAsBytes();

      final imageUrl = await _firestoreService.uploadChatImage(
        'status_$currentUid',
        bytes,
        picked.name,
      );

      final status = StatusModel(
        id: '',
        uid: currentUid,
        userName: userName,
        type: StatusType.image,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      await _firestoreService.postStatus(status);
    } finally {
      isPosting.value = false;
    }
  }
}