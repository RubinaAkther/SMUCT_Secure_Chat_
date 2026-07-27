import 'package:chatapp/controllers/chat_controller.dart';
import 'package:chatapp/models/call_model.dart';
import 'package:chatapp/models/message_model.dart';
import 'package:chatapp/services/firestore_service.dart';
import 'package:chatapp/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  late final ChatController _chatController;
  late final String _chatId;
  late final String _name;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _chatId = args['chatId'] ?? '';
    _name = args['name'] ?? 'Chat';
    // tag ensures a fresh controller per chatId (so switching chats doesn't reuse old messages)
    _chatController = Get.put(ChatController(chatId: _chatId), tag: _chatId);
  }

  @override
  void dispose() {
    _messageController.dispose();
    Get.delete<ChatController>(tag: _chatId);
    super.dispose();
  }

  Future<void> _logCall(CallType type) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final otherUid = _chatId.split('_').firstWhere(
          (id) => id != currentUid,
          orElse: () => '',
        );

    final currentUser = await FirestoreService().getUser(currentUid);

    final call = CallModel(
      id: '',
      callerId: currentUid,
      callerName: currentUser?.name ?? 'You',
      receiverId: otherUid,
      receiverName: _name,
      type: type,
      calledAt: DateTime.now(),
    );

    await FirestoreService().logCall(call);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${type == CallType.video ? "Video" : "Voice"} call logged (demo)',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_name),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () => _logCall(CallType.video),
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => _logCall(CallType.voice),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (_chatController.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_chatController.messages.isEmpty) {
                return const Center(child: Text('Say hi 👋'));
              }
              return ListView.builder(
                reverse: true, // newest message at the bottom
                padding: const EdgeInsets.all(12),
                itemCount: _chatController.messages.length,
                itemBuilder: (context, index) {
                  final message = _chatController.messages[index];
                  final isMe = message.senderId == _chatController.currentUid;
                  return _MessageBubble(message: message, isMe: isMe);
                },
              );
            }),
          ),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Obx(
        () => Row(
          children: [
            IconButton(
              icon: const Icon(Icons.emoji_emotions_outlined),
              onPressed: () {},
            ),
            _chatController.isUploadingImage.value
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: () => _chatController.sendImageMessage(),
                  ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Type a message',
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              color: AppTheme.waGreen,
              onPressed: () {
                _chatController.sendTextMessage(_messageController.text);
                _messageController.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final isImage =
        message.type == MessageType.image && message.mediaUrl != null;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: isImage
            ? const EdgeInsets.all(4)
            : const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.65,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? AppTheme.sentBubbleColor(context)
              : AppTheme.receivedBubbleColor(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: isImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  message.mediaUrl!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      height: 150,
                      width: 150,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (context, error, stack) =>
                      const Icon(Icons.broken_image, size: 60),
                ),
              )
            : Text(message.text),
      ),
    );
  }
}
