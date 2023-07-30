import 'package:brycen_chatbot/firebase_options.dart';
import 'package:brycen_chatbot/widget/chat/chat_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intern Chatbot',
      home: GetUserName(),
    );
  }
}

class GetUserName extends StatefulWidget {
  const GetUserName({super.key});

  @override
  State<GetUserName> createState() => _GetUserNameState();
}

class _GetUserNameState extends State<GetUserName> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc('VC0AAVpP10HLI3ghTO5D')
          .collection('chat')
          .orderBy(
            "createdAt",
            descending: true,
          )
          .snapshots(),
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.hasError) {
          return Scaffold(
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
              child: CircularProgressIndicator(),
            );
          case ConnectionState.none:
            return const Expanded(
              child: Center(
                child: Text('No Data'),
              ),
            );
          case ConnectionState.active:
            final loadedMessages = List.from(chatSnapshots.data!.docs.reversed);
            final lengthHistory = loadedMessages.length;
            print(lengthHistory);
            responseChain(loadedMessages);
            return Scaffold(
              body: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
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
                ],
              ),
            );
          case ConnectionState.done:
            break;
        }
        return const Center(child: Text('error'));
      },
    );
  }

  void responseChain(List<dynamic> loadedMessages) async {
    final llm = ChatOpenAI(
        apiKey:
            // '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   x',
            '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',
        temperature: 0);
    // .generate([ChatMessage.human('Flutter là gì trong 3 câu.')]);
    // print(llm);
    var memo = ConversationBufferMemory();
    for (final item in loadedMessages) {
      memo.saveContext(
          inputValues: {'Human': item.data()['Human']},
          outputValues: {'AI': item.data()['AI']});
    }

    var conversation = ConversationChain(llm: llm, memory: memo);
    // print(conversation.memory!.loadMemoryVariables());

    final result = await conversation.run('Flutter là gì trong 3 câu.');
    print(result);
  }
}
