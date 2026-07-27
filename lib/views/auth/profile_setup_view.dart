import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chatapp/controllers/auth_controller.dart';
import 'package:chatapp/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileSetupView extends StatefulWidget {
  const ProfileSetupView({super.key});

  @override
  State<ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends State<ProfileSetupView> {
  final TextEditingController _nameController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();

  Uint8List? _pickedImageBytes;
  bool _isUploadingPhoto = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _pickedImageBytes = bytes;
    });
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Error', 'Please enter your name');
      return;
    }

    String? photoUrl;

    if (_pickedImageBytes != null) {
      setState(() => _isUploadingPhoto = true);
      try {
        final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
        photoUrl = await FirestoreService().uploadChatImage(
          'profile_$uid',
          _pickedImageBytes!,
          'profile.jpg',
        );
      } catch (e) {
        Get.snackbar('Error', 'Photo upload failed, saving without photo');
      } finally {
        setState(() => _isUploadingPhoto = false);
      }
    }

    await _authController.saveProfile(name: name, photoUrl: photoUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set up your profile')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: _pickedImageBytes != null
                        ? MemoryImage(_pickedImageBytes!)
                        : null,
                    child: _pickedImageBytes == null
                        ? const Icon(Icons.camera_alt, size: 32)
                        : null,
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, size: 16, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_authController.isLoading.value || _isUploadingPhoto)
                      ? null
                      : _saveProfile,
                  child: (_authController.isLoading.value || _isUploadingPhoto)
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}