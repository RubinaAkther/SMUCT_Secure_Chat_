import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatapp/routes/app_routes.dart';

class ChatSearchItem {
  final String chatId;
  final String name;

  ChatSearchItem({required this.chatId, required this.name});
}

class ChatSearchDelegate extends SearchDelegate<void> {
  final List<ChatSearchItem> items;

  ChatSearchDelegate(this.items);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final filtered = query.isEmpty
        ? items
        : items
            .where((item) =>
                item.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No chats found'));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(item.name),
          onTap: () {
            close(context, null);
            Get.toNamed(
              AppRoutes.chatScreen,
              arguments: {'chatId': item.chatId, 'name': item.name},
            );
          },
        );
      },
    );
  }
}