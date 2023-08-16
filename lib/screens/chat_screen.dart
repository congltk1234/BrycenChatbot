// ignore_for_file: avoid_print

import 'package:brycen_chatbot/widget/internet_error.dart';
import 'package:connection_notifier/connection_notifier.dart';

import '../widget/app_bar.dart';
import '../widget/chat/chat_item.dart';
import '../widget/chat/text_and_voice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class ChatScreen extends StatefulWidget {
  ChatScreen({
    super.key,
    required this.chatTitleID,
    required this.chatTitle,
    required this.uid,
    required this.apiKey,
    required this.userName,
  });
  String chatTitleID;
  String chatTitle;
  String uid;
  String apiKey;
  String userName;
  @override
  State<StatefulWidget> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  // ignore: non_constant_identifier_names
  int k_memory = 3;
  var _memoryBuffer = '';
  late List<dynamic> memory;

  late ScrollController _listScrollController;
  final bool _needsScroll = true;
  late FocusNode focusNode;

  @override
  void initState() {
    _listScrollController = ScrollController();
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    focusNode.dispose();
    super.dispose();
  }

// Auto scroll to newest message
  void scrollListToEND() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(widget.uid)
          .collection('chat')
          .doc(widget.chatTitleID)
          .collection('chat_history')
          .orderBy(
            "createdAt",
            descending: true,
          )
          .snapshots(),
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.hasError) {
          return Scaffold(
            appBar: const ConfigAppBar(title: 'Chat Screen'),
            body: Expanded(
              child: Center(
                child: Text('Error: ${chatSnapshots.error}'),
              ),
            ),
          );
        }
        switch (chatSnapshots.connectionState) {
          case ConnectionState.waiting:
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: Color.fromARGB(255, 255, 246, 246),
              ),
            );
          case ConnectionState.none:
            return const Expanded(
              child: Center(
                child: Text('No Data'),
              ),
            );
          case ConnectionState.active:
            if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
              return Scaffold(
                appBar: ConfigAppBar(title: widget.chatTitle),
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
                        uid: widget.uid,
                        userName: widget.userName,
                        apiKey: widget.apiKey,
                        memory: _memoryBuffer,
                        taskMode: 'chat',
                        chatID: widget.chatTitleID,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            }

            ////////// Handle OutofList error
            final loadedMessages = List.from(chatSnapshots.data!.docs.reversed);
            final lengthHistory = loadedMessages.length;
            memory = lengthHistory >= (k_memory)
                ? loadedMessages.sublist(
                    lengthHistory - k_memory, lengthHistory)
                : loadedMessages.sublist(0, lengthHistory - 1);

            _memoryBuffer = '';
            for (var msg in memory) {
              _memoryBuffer =
                  "$_memoryBuffer\nHuman:${msg.data()['Human']}\nAI:${msg.data()['AI']}";
            }

            if (_needsScroll) {
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => scrollListToEND());
              // _needsScroll = false;
            }
            print(widget.chatTitleID);
            return Scaffold(
              appBar: ConfigAppBar(title: widget.chatTitle),
              body: ConnectionNotifierToggler(
                onConnectionStatusChanged: (connected) {
                  if (connected == null) return;
                },
                disconnected: const InternetError(),
                connected: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                          controller: _listScrollController,
                          itemCount: lengthHistory,
                          itemBuilder: (context, index) {
                            final chatMessage = loadedMessages[index].data();

                            return ChatItem(
                              humanMessage: chatMessage["Human"],
                              botResponse: chatMessage["AI"],
                              tokens: chatMessage["totalTokens"],
                              timeStamp: DateFormat.yMMMd().add_jm().format(
                                  DateTime.parse(chatMessage["createdAt"]
                                      .toDate()
                                      .toString())),
                              shouldAnimate: lengthHistory < 1
                                  ? lengthHistory == index
                                  : lengthHistory - 1 == index,
                            );
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextAndVoiceField(
                        uid: widget.uid,
                        userName: widget.userName,
                        apiKey: widget.apiKey,
                        memory: _memoryBuffer,
                        taskMode: 'chat',
                        chatID: widget.chatTitleID,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          case ConnectionState.done:
            break;
        }
        return const Center(child: Text('error'));
      },
    );
  }
}
