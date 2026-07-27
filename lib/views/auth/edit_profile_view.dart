import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/controllers/auth_controller.dart';
import 'package:chatapp/services/firestore_service.dart';
import 'package:chatapp/models/user_model.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final TextEditingController _nameController = TextEditingController();
  final AuthController _authController = Get.isRegistered<AuthController>()
      ? Get.find<AuthController>()
      : Get.put(AuthController());

  Uint8List? _pickedImageBytes;
  String? _existingPhotoUrl;
  bool _isLoadingUser = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final user = await FirestoreService().getUser(uid);
    if (user != null && mounted) {
      setState(() {
        _nameController.text = user.name;
        _existingPhotoUrl = user.photoUrl;
        _isLoadingUser = false;
      });
    } else if (mounted) {
      setState(() => _isLoadingUser = false);
    }
  }

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

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Error', 'Please enter your name');
      return;
    }

    setState(() => _isSaving = true);

    String? photoUrl = _existingPhotoUrl;

    if (_pickedImageBytes != null) {
      try {
        final uid = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
        photoUrl = await FirestoreService().uploadChatImage(
          'profile_$uid',
          _pickedImageBytes!,
          'profile.jpg',
        );
      } catch (e) {
        Get.snackbar('Error', 'Photo upload failed');
      }
    }

    await _authController.saveProfile(
      name: name,
      photoUrl: photoUrl,
      navigateHome: false,
    );

    setState(() => _isSaving = false);

    if (mounted) {
      Get.snackbar('Success', 'Profile updated');
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: _isLoadingUser
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                              : (_existingPhotoUrl != null &&
                                        _existingPhotoUrl!.isNotEmpty
                                    ? NetworkImage(_existingPhotoUrl!)
                                        as ImageProvider
                                    : null),
                          child: (_pickedImageBytes == null &&
                                  (_existingPhotoUrl == null ||
                                      _existingPhotoUrl!.isEmpty))
                              ? const Icon(Icons.camera_alt, size: 32)
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.white,
                          ),
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}