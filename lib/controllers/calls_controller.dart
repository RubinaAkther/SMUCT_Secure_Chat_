


import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/services/firestore_service.dart';
import 'package:chatapp/models/call_model.dart';

class CallsController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();

  final RxList<CallModel> calls = <CallModel>[].obs;
  final RxBool isLoading = true.obs;

  String get currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    _listenToCalls();
  }

  void _listenToCalls() {
    if (currentUid.isEmpty) return;
    _firestoreService.watchUserCalls(currentUid).listen((list) {
      calls.value = list;
      isLoading.value = false;
    });
  }
}