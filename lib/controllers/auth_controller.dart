

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/services/auth_service.dart';
import 'package:chatapp/services/firestore_service.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  final RxBool isLoading = false.obs;
  final RxString phoneNumber = ''.obs;
  String? _verificationId;

  /// Called from LoginView
  Future<void> sendOtp(String phone) async {
    isLoading.value = true;
    phoneNumber.value = phone;

    await _authService.sendOtp(
      phoneNumber: phone,
      onCodeSent: (verificationId) {
        _verificationId = verificationId;
        isLoading.value = false;
        Get.toNamed(AppRoutes.otpVerification, arguments: {'phone': phone});
      },
      onError: (e) {
        isLoading.value = false;
        Get.snackbar('OTP Error', e.message ?? 'Failed to send OTP');
      },
      onAutoVerified: (user) {
        isLoading.value = false;
        _afterLogin(user);
      },
    );
  }

  /// Called from OtpVerificationView
  Future<void> verifyOtp(String smsCode) async {
    if (_verificationId == null) {
      Get.snackbar('Error', 'Please request OTP again');
      return;
    }
    isLoading.value = true;
    try {
      final user = await _authService.verifyOtp(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      isLoading.value = false;
      if (user != null) await _afterLogin(user);
    } on FirebaseAuthException catch (e) {
      isLoading.value = false;
      Get.snackbar('Verification Failed', e.message ?? 'Invalid code');
    }
  }

  Future<void> _afterLogin(User user) async {
    final existingUser = await _firestoreService.getUser(user.uid);
    if (existingUser == null) {
      // first-time user -> profile setup
      Get.offAllNamed(AppRoutes.profileSetup);
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  /// Called from ProfileSetupView
  /// Called from ProfileSetupView / EditProfileView
  Future<void> saveProfile({
    required String name,
    String? photoUrl,
    bool navigateHome = true,
  }) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;

    isLoading.value = true;

    // Preserve existing photo if a new one wasn't provided (e.g. editing name only)
    String? finalPhotoUrl = photoUrl;
    if (finalPhotoUrl == null) {
      final existing = await _firestoreService.getUser(uid);
      finalPhotoUrl = existing?.photoUrl;
    }

    await _firestoreService.createOrUpdateUser(
      UserModel(
        uid: uid,
        name: name,
        phone: phoneNumber.value,
        photoUrl: finalPhotoUrl,
      ),
    );
    isLoading.value = false;

    if (navigateHome) {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    Get.offAllNamed(AppRoutes.login);
  }
}