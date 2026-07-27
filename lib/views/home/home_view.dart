import 'package:chatapp/controllers/auth_controller.dart';
import 'package:chatapp/controllers/calls_controller.dart';
import 'package:chatapp/controllers/home_controller.dart';
import 'package:chatapp/controllers/status_controller.dart';
import 'package:chatapp/models/call_model.dart';
import 'package:chatapp/models/chat_model.dart';
import 'package:chatapp/models/status_model.dart';
import 'package:chatapp/models/user_model.dart';
import 'package:chatapp/routes/app_routes.dart';
import 'package:chatapp/services/firestore_service.dart';
import 'package:chatapp/theme/app_theme.dart';
import 'package:chatapp/views/common/coming_soon_view.dart';
import 'package:chatapp/views/home/chat_search_delegate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatapp/views/auth/edit_profile_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentTab = 0;

  final List<Widget> _tabs = const [_ChatsTab(), _StatusTab(), _CallsTab()];

  void _onFabPressed() {
    if (_currentTab == 0) {
      Get.toNamed(AppRoutes.newChat);
    } else if (_currentTab == 1) {
      _showAddStatusSheet(context);
    }
  }

  Future<void> _openSearch(BuildContext context) async {
    final homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());

    final items = await Future.wait(
      homeController.chats.map((chat) async {
        final otherUid = chat.participantIds.firstWhere(
          (id) => id != homeController.currentUid,
          orElse: () => '',
        );
        final user = await FirestoreService().getUser(otherUid);
        return ChatSearchItem(
          chatId: chat.chatId,
          name: user?.name ?? 'Unknown',
        );
      }),
    );

    if (context.mounted) {
      showSearch(context: context, delegate: ChatSearchDelegate(items));
    }
  }

  void _onMenuSelected(BuildContext context, String value) {
    switch (value) {
      case 'new_group':
        Get.to(() => const ComingSoonView(title: 'New Group'));
        break;
      case 'starred':
        Get.to(() => const ComingSoonView(title: 'Starred Messages'));
        break;
      case 'settings':
        Get.to(() => const EditProfileView());
        break;
      case 'logout':
        _confirmLogout(context);
        break;
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              final authController = Get.isRegistered<AuthController>()
                  ? Get.find<AuthController>()
                  : Get.put(AuthController());
              authController.logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showAddStatusSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: const Text('Text status'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showTextStatusDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Photo status'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final statusController = Get.find<StatusController>();
                  final currentUid =
                      FirebaseAuth.instance.currentUser?.uid ?? '';
                  final user = await FirestoreService().getUser(currentUid);
                  await statusController.postImageStatus(
                    user?.name ?? 'Unknown',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTextStatusDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add text status'),
          content: TextField(
            controller: textController,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(hintText: "What's on your mind?"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final statusController = Get.find<StatusController>();
                final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
                final user = await FirestoreService().getUser(currentUid);
                await statusController.postTextStatus(
                  textController.text,
                  user?.name ?? 'Unknown',
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Post'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.lock, size: 20),
            SizedBox(width: 8),
            Flexible(child: Text('SafeTalk', overflow: TextOverflow.ellipsis)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _openSearch(context),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _onMenuSelected(context, value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'new_group', child: Text('New group')),
              PopupMenuItem(value: 'starred', child: Text('Starred messages')),
              PopupMenuItem(value: 'settings', child: Text('Settings')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: _tabs[_currentTab],
      floatingActionButton: (_currentTab == 0 || _currentTab == 1)
          ? Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: FloatingActionButton(
                onPressed: _onFabPressed,
                child: Icon(_currentTab == 0 ? Icons.chat : Icons.camera_alt),
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) => setState(() => _currentTab = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.donut_large),
            label: 'Status',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.call), label: 'Calls'),
        ],
      ),
    );
  }
}

class _ChatsTab extends StatelessWidget {
  const _ChatsTab();

  @override
  Widget build(BuildContext context) {
    final homeController = Get.put(HomeController());

    return Obx(() {
      if (homeController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (homeController.chats.isEmpty) {
        return const Center(child: Text('No chats yet. Tap + to start one.'));
      }
      return ListView.separated(
        itemCount: homeController.chats.length,
        separatorBuilder: (_, _) => const Divider(
          height: 1,
          thickness: 0.3,
          indent: 72, // Avatar-এর পর থেকে শুরু হবে
          endIndent: 16,
          color: Color.fromARGB(255, 92, 92, 92),
        ),
        itemBuilder: (context, index) {
          final chat = homeController.chats[index];
          return _ChatTile(chat: chat, currentUid: homeController.currentUid);
        },
      );
    });
  }
}

class _ChatTile extends StatelessWidget {
  final ChatModel chat;
  final String currentUid;

  const _ChatTile({required this.chat, required this.currentUid});

  @override
  Widget build(BuildContext context) {
    final otherUid = chat.participantIds.firstWhere(
      (id) => id != currentUid,
      orElse: () => '',
    );

    return FutureBuilder<UserModel?>(
      future: FirestoreService().getUser(otherUid),
      builder: (context, snapshot) {
        final name = snapshot.data?.name ?? 'Loading...';

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: (snapshot.data?.photoUrl != null &&
                    snapshot.data!.photoUrl!.isNotEmpty)
                ? NetworkImage(snapshot.data!.photoUrl!)
                : null,
            child: (snapshot.data?.photoUrl == null ||
                    snapshot.data!.photoUrl!.isEmpty)
                ? const Icon(Icons.person)
                : null,
          ),
          title: Text(name),
          subtitle: Text(
            chat.lastMessage.isEmpty ? 'Say hi' : chat.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => Get.toNamed(
            AppRoutes.chatScreen,
            arguments: {'chatId': chat.chatId, 'name': name},
          ),
        );
      },
    );
  }
}

class _StatusTab extends StatelessWidget {
  const _StatusTab();

  void _openStatusViewer(BuildContext context, StatusModel status) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              SizedBox.expand(
                child:
                    status.type == StatusType.image && status.imageUrl != null
                    ? Image.network(status.imageUrl!, fit: BoxFit.contain)
                    : Container(
                        color: AppTheme.waGreen,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          status.text ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ),
              ),
              Positioned(
                top: 40,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        status.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(dialogContext),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusController = Get.put(StatusController());

    return Obx(() {
      if (statusController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (statusController.statuses.isEmpty) {
        return const Center(
          child: Text('No status updates yet. Tap 📷 to add one.'),
        );
      }
      return ListView.separated(
        itemCount: statusController.statuses.length,
        separatorBuilder: (_, _) => const Divider(
          height: 1,
          thickness: 0.3,
          indent: 72, // Avatar-এর পর থেকে শুরু
          endIndent: 16,
          color: Color.fromARGB(255, 95, 95, 95),
        ),
        itemBuilder: (context, index) {
          final status = statusController.statuses[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.waGreen,
              child: Icon(
                status.type == StatusType.image
                    ? Icons.photo
                    : Icons.text_fields,
                color: Colors.white,
              ),
            ),
            title: Text(status.userName),
            subtitle: Text(
              status.type == StatusType.image
                  ? 'Photo status'
                  : (status.text ?? ''),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _openStatusViewer(context, status),
          );
        },
      );
    });
  }
}

class _CallsTab extends StatelessWidget {
  const _CallsTab();

  @override
  Widget build(BuildContext context) {
    final callsController = Get.put(CallsController());

    return Obx(() {
      if (callsController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (callsController.calls.isEmpty) {
        return const Center(child: Text('No call history yet.'));
      }
      return ListView.separated(
        itemCount: callsController.calls.length,
        separatorBuilder: (_, _) => const Divider(
          height: 1,
          thickness: 0.3,
          indent: 72, // Avatar-এর পর থেকে শুরু হবে
          endIndent: 16,
          color: Color.fromARGB(255, 95, 95, 95),
        ),
        itemBuilder: (context, index) {
          final call = callsController.calls[index];
          final isOutgoing = call.callerId == callsController.currentUid;
          final otherName = isOutgoing ? call.receiverName : call.callerName;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.waGreen,
              child: Icon(
                call.type == CallType.video ? Icons.videocam : Icons.call,
                color: Colors.white,
              ),
            ),
            title: Text(otherName),
            subtitle: Row(
              children: [
                Icon(
                  isOutgoing ? Icons.call_made : Icons.call_received,
                  size: 16,
                  color: isOutgoing ? Colors.grey : Colors.green,
                ),
                const SizedBox(width: 4),
                Text(_formatTime(call.calledAt)),
              ],
            ),
            trailing: Icon(
              call.type == CallType.video ? Icons.videocam : Icons.call,
              color: AppTheme.waGreen,
            ),
          );
        },
      );
    });
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final time = '$hour:${dt.minute.toString().padLeft(2, '0')} $period';
    return isToday ? time : '${dt.day}/${dt.month}/${dt.year}';
  }
}
