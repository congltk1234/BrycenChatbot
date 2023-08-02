import 'package:brycen_chatbot/values/share_keys.dart';
import 'package:brycen_chatbot/widget/app_bar.dart';
import 'package:brycen_chatbot/widget/chat/chat_item.dart';
import 'package:brycen_chatbot/widget/chat/text_and_voice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _template = '''
Write a concise summary of the following:

"{context}"

then give 3 short related questions. Response with following:

"SUMMARY

<br>
QUESTION 1

<br>
QUESTION 2

<br>
QUESTION 3"
 ''';

class SummarizeScreen extends StatefulWidget {
  const SummarizeScreen({super.key});
  static const id = 'summarize_screen';

  @override
  State<StatefulWidget> createState() {
    return _SummarizeScreenstate();
  }
}

class _SummarizeScreenstate extends State<SummarizeScreen> {
  bool _hasFiled = true;
  String _fileUID = 'fYabgYtvbowVSUfsFy9R';
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

  void _uploadedFile(String uid, String openAIKey, String path) async {
    TextLoader loader = TextLoader(path);

    final fileID = await FirebaseFirestore.instance
        .collection("users")
        .doc(_initUID)
        .collection('summarize')
        .where('FilePath', isEqualTo: path)
        .get();

    const textSplitter = RecursiveCharacterTextSplitter();
    final docs = await loader.load();

    final docsChunks = textSplitter.splitDocuments(docs);
    /////
    //// Embedding and stored Embedded Vectors
    final textsWithSources = docsChunks
        .mapIndexed(
          (final i, final d) => d.copyWith(
            metadata: {
              ...d.metadata,
              'source': '$i-pl',
            },
          ),
        )
        .toList(growable: false);
    final embeddings = OpenAIEmbeddings(apiKey: openAIKey);
    final docSearch = await MemoryVectorStore.fromDocuments(
      documents: textsWithSources,
      embeddings: embeddings,
    );
    for (var element in docSearch.memoryVectors) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(_initUID)
          .collection('summarize')
          .doc(fileID.docs.first.reference.id)
          .collection("embeddedVectors")
          .add({
        "content": element.content,
        "embed": element.embedding,
        'metadata': element.metadata
      });
    }
//////////////////////////////
    final llm = ChatOpenAI(apiKey: openAIKey, model: 'gpt-3.5-turbo-16k-0613');

    final docPrompt = PromptTemplate.fromTemplate(_template);
    final summarizeChain = SummarizeChain.stuff(
      llm: llm,
      promptTemplate: docPrompt,
    );

    final summary = await summarizeChain.run(docsChunks);
    final re = RegExp(r'((Question)|(question)|(QUESTION)) \d: ');
    final suggestList = summary.split(re);

    final shortSummary = suggestList.removeAt(0);

    await FirebaseFirestore.instance
        .collection("users")
        .doc(_initUID)
        .collection('summarize')
        .doc(fileID.docs.first.reference.id)
        .collection('QuestionAnswering')
        .add({
      "AI": shortSummary,
      'Human': '',
      'totalTokens': 0,
      "createdAt": Timestamp.now(),
    });

    suggestList.add("What's the main topic?");
    for (var i in suggestList) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(_initUID)
          .collection('summarize')
          .doc(fileID.docs.first.reference.id)
          .collection("suggestion")
          .add({
        "suggestQuestion": i,
        "createdAt": Timestamp.now(),
      });
    }

    setState(() {
      _hasFiled = true;
      _fileUID = fileID.docs.first.reference.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return !_hasFiled
        ? Scaffold(
            appBar: const ConfigAppBar(title: 'Summarize Screen'),
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: ElevatedButton.icon(
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all<Size>(
                            const Size(
                              200,
                              70,
                            ),
                          ),
                        ),
                        icon: const Icon(
                          Icons.cloud_upload,
                          size: 30,
                        ),
                        label: const Text(
                          "Upload File",
                          style: TextStyle(fontSize: 25),
                        ),
                        onPressed: () async {
                          final result = await FilePicker.platform
                              .pickFiles(withData: true);

                          if (result == null) return;
                          PlatformFile file = result.files.first;

                          FirebaseFirestore.instance
                              .collection("users")
                              .doc(_initUID)
                              .collection('summarize')
                              .add(
                            {
                              "FilePath": file.path,
                              "createdAt": Timestamp.now(),
                            },
                          );

                          final path = file.path;
                          _uploadedFile(
                            _initUID,
                            _initAPIKey,
                            path!,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("users")
                .doc(_initUID)
                .collection('summarize')
                .doc(_fileUID)
                .collection('QuestionAnswering')
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
                  if (!chatSnapshots.hasData ||
                      chatSnapshots.data!.docs.isEmpty) {
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

                  ////////// Handle OutofList error
                  final loadedMessages =
                      List.from(chatSnapshots.data!.docs.reversed);
                  final lengthHistory = loadedMessages.length;
                  // memory = lengthHistory >= (k_memory)
                  //     ? loadedMessages.sublist(
                  //         lengthHistory - k_memory, lengthHistory)
                  //     : loadedMessages.sublist(0, lengthHistory - 1);

                  _memoryBuffer = '';
                  // for (var msg in memory) {
                  //   _memoryBuffer =
                  //       "$_memoryBuffer\nHuman:${msg.data()['Human']}\nAI:${msg.data()['AI']}";
                  // }
                  // print(_memoryBuffer);

                  // if (_needsScroll) {
                  //   WidgetsBinding.instance
                  //       .addPostFrameCallback((_) => scrollListToEND());
                  //   // _needsScroll = false;
                  // }
                  return Scaffold(
                    appBar: const ConfigAppBar(title: 'Chat Screen'),
                    body: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                              controller: _listScrollController,
                              itemCount: lengthHistory,
                              itemBuilder: (context, index) {
                                final chatMessage =
                                    loadedMessages[index].data();

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
