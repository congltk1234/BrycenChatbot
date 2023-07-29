import 'package:brycen_chatbot/widget/chat/chat_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  ChatMessages({
    super.key,
    required this.initUID,
  });

  String initUID;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(initUID)
            .collection('chat')
            .orderBy(
              "createdAt",
              descending: true,
            )
            .snapshots(),
        builder: (ctx, chatSnapshots) {
          if (chatSnapshots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final loadedMessages = chatSnapshots.data!.docs;
          return ListView.builder(
              reverse: true,
              itemCount: loadedMessages.length,
              itemBuilder: (context, index) {
                final chatMessage = loadedMessages[index].data();
                return ChatItem(
                  text: chatMessage["text"],
                  isUser: chatMessage["isUser"],
                );
              });
        });
  }
}
