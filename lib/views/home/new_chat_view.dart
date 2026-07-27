import 'package:chatapp/controllers/home_controller.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/routes/app_routes.dart';
import 'package:chatapp/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewChatView extends StatelessWidget {
  const NewChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Select contact')),
      body: FutureBuilder<List<UserModel>>(
        future: FirestoreService().getAllUsersExcept(homeController.currentUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(child: Text('No other users found yet.'));
          }
          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, _) => const Divider(
              height: 1,
              thickness: 0.3,
              indent: 72, // Avatar-এর পর থেকে শুরু হবে
              endIndent: 16,
              color: Color.fromARGB(255, 102, 102, 102),
            ),
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(user.name),
                subtitle: Text(user.phone),
                onTap: () async {
                  final chatId = await homeController.openChatWith(user.uid);
                  Get.offNamed(
                    AppRoutes.chatScreen,
                    arguments: {'chatId': chatId, 'name': user.name},
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
