import 'package:brycen_chatbot/widget/app_bar.dart';
import 'package:flutter/material.dart';

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
      appBar: ConfigAppBar(title: 'Chat Screen'),
    );
  }
}
