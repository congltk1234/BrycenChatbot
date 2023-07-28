import 'package:brycen_chatbot/providers/chat_provider.dart';
import 'package:brycen_chatbot/widget/app_bar.dart';
import 'package:brycen_chatbot/widget/chat/chat_item.dart';
import 'package:brycen_chatbot/widget/chat/text_and_voice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  static const id = 'chat_screen';

  @override
  State<StatefulWidget> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ConfigAppBar(title: 'Chat Screen'),
      body: Column(
        children: [
          Expanded(
            child: Consumer(builder: (context, ref, child) {
              final chats = ref.watch(chatsProvider).reversed.toList();
              return ListView.builder(
                reverse: true,
                itemCount: chats.length,
                itemBuilder: (context, index) => ChatItem(
                  text: chats[index].message,
                  isUser: chats[index].isUser,
                ),
              );
            }),
          ),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: TextAndVoiceField(),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
