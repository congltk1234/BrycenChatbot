import 'package:brycen_chatbot/values/share_keys.dart';
import 'package:brycen_chatbot/widget/app_bar.dart';
import 'package:brycen_chatbot/widget/chat/chat_item.dart';
import 'package:brycen_chatbot/widget/chat/text_and_voice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  static const id = 'chat_screen';

  @override
  State<StatefulWidget> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  late SharedPreferences prefs;
  String _initUID = 'id';
  String _initAPIKey = '';
  String _initUsername = '';

  int k_memory = 6;
  var _memoryBuffer = '';

  @override
  void initState() {
    _getLocalValue();
    super.initState();
  }

  void _getLocalValue() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _initAPIKey = prefs.getString(ShareKeys.APIkey) ?? '';
      _initUsername = prefs.getString(ShareKeys.Username) ?? '';
      _initUID = prefs.getString(ShareKeys.UID) ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    // FirebaseFirestore.instance.doc('users/$userID').;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(_initUID)
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
          if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
            return Scaffold(
              appBar: const ConfigAppBar(title: 'Chat Screen'),
              body: Column(
                children: [
                  const Expanded(
                    child: Center(
                      child: Text('No messages found.'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextAndVoiceField(
                      uid: _initUID,
                      userName: _initUsername,
                      apiKey: _initAPIKey,
                      memory: _memoryBuffer,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          }
          if (chatSnapshots.hasError) {
            return Scaffold(
              appBar: const ConfigAppBar(title: 'Chat Screen'),
              body: Column(
                children: [
                  const Expanded(
                    child: Center(
                      child: Text('Something went wrong...'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextAndVoiceField(
                      uid: _initUID,
                      userName: _initUsername,
                      apiKey: _initAPIKey,
                      memory: _memoryBuffer,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          }
          final loadedMessages = List.from(chatSnapshots.data!.docs.reversed);
          final lengthHistory = loadedMessages.length;
          final memory = lengthHistory >= (k_memory)
              ? loadedMessages.sublist(
                  lengthHistory - k_memory + 2, lengthHistory)
              : loadedMessages.sublist(0, lengthHistory - 2);
          for (var msg in memory) {
            if (msg.data()['isUser']) {
              _memoryBuffer = "$_memoryBuffer\nHuman:";
            } else {
              _memoryBuffer = "$_memoryBuffer\nAI:";
            }
            _memoryBuffer = _memoryBuffer + msg.data()['text'];
          }

          return Scaffold(
            appBar: const ConfigAppBar(title: 'Chat Screen'),
            body: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                      itemCount: lengthHistory,
                      itemBuilder: (context, index) {
                        final chatMessage = loadedMessages[index].data();
                        return ChatItem(
                          text: chatMessage["text"],
                          isUser: chatMessage["isUser"],
                        );
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextAndVoiceField(
                    uid: _initUID,
                    userName: _initUsername,
                    apiKey: _initAPIKey,
                    memory: _memoryBuffer,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        });
  }
}
