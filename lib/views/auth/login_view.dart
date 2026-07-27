import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatapp/controllers/auth_controller.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _phoneController = TextEditingController();
  final AuthController _authController = Get.put(AuthController());

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      Get.snackbar('Error', 'Please enter a phone number');
      return;
    }
    // Adjust the country code prefix as needed for your users.
    _authController.sendOtp('+880$phone');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter your phone number')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SafeTalk will send an SMS to verify your phone number.',
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                prefixText: '+880 ',
                hintText: '1XXXXXXXXX',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _authController.isLoading.value ? null : _sendOtp,
                  child: _authController.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Send OTP'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}