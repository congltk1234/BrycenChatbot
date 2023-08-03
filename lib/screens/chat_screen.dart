import 'package:brycen_chatbot/values/share_keys.dart';
import 'package:brycen_chatbot/widget/app_bar.dart';
import 'package:brycen_chatbot/widget/chat/chat_item.dart';
import 'package:brycen_chatbot/widget/chat/text_and_voice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

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

  int k_memory = 3;
  var _memoryBuffer = '';
  late List<dynamic> memory;

  late ScrollController _listScrollController;
  bool _needsScroll = true;
  late FocusNode focusNode;

  @override
  void initState() {
    _listScrollController = ScrollController();
    focusNode = FocusNode();
    _getLocalValue();
    super.initState();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void scrollListToEND() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut);
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
                          taskMode: 'chat',
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              }

              ////////// Handle OutofList error
              final loadedMessages =
                  List.from(chatSnapshots.data!.docs.reversed);
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
              print(_memoryBuffer);

              if (_needsScroll) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => scrollListToEND());
                // _needsScroll = false;
              }
              return Scaffold(
                appBar: const ConfigAppBar(title: 'Chat Screen'),
                body: Column(
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
                        uid: _initUID,
                        userName: _initUsername,
                        apiKey: _initAPIKey,
                        memory: _memoryBuffer,
                        taskMode: 'chat',
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            case ConnectionState.done:
              break;
          }
          return Center(child: Text('error'));
        });
  }
}
