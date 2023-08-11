import 'package:brycen_chatbot/const/prompt.dart';
import 'package:brycen_chatbot/models/suggestQuestion.dart';
import 'package:brycen_chatbot/providers/suggest_provider.dart';
import 'package:brycen_chatbot/widget/app_bar.dart';
import 'package:brycen_chatbot/widget/chat/chat_item.dart';
import 'package:brycen_chatbot/widget/chat/text_and_voice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:collection/collection.dart';

class SummarizeScreen extends ConsumerStatefulWidget {
  SummarizeScreen({
    super.key,
    required this.chatTitleID,
    required this.chatTitle,
    required this.uid,
    required this.apiKey,
    required this.userName,
    required this.hasFile,
  });
  static const id = 'summarize_screen';
  String chatTitleID;
  String chatTitle;
  String uid;
  String apiKey;
  String userName;
  bool hasFile;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _SummarizeScreenstate();
  }
}

class _SummarizeScreenstate extends ConsumerState<SummarizeScreen> {
  int k_memory = 3;
  var _memoryBuffer = '';
  late List<dynamic> memory;
  var _isLoading = false;
  late ScrollController _listScrollController;
  bool _needsScroll = true;
  late FocusNode focusNode;

  @override
  void initState() {
    _listScrollController = ScrollController();
    focusNode = FocusNode();
    print(widget.chatTitleID);
    ref
        .read(suggestProvider.notifier)
        .fetchDatafromFireStore(widget.uid, widget.chatTitleID);
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

  void documentQA(String message) async {
    final embeddings = OpenAIEmbeddings(apiKey: widget.apiKey);
    final llm =
        ChatOpenAI(apiKey: widget.apiKey, model: 'gpt-3.5-turbo-16k-0613');

    final storedVectors = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .collection('summarize')
        .doc(widget.chatTitleID)
        .collection("embeddedVectors")
        .get();

    List<List<double>> vectorList = [];
    List<Document> docList = [];

    for (var element in storedVectors.docs) {
      List<double> embedded =
          List<double>.from(element.data()['embed'] as List);
      vectorList.add(embedded);
      docList.add(Document(
          pageContent: element.data()['content'],
          metadata: element.data()['metadata']));
    }
    print('load vector');
    final listVector = MemoryVectorStore(embeddings: embeddings);
    listVector.addVectors(vectors: vectorList, documents: docList);
    listVector.similaritySearch(query: 'User prompt');

    final qaChain = OpenAIQAWithSourcesChain(llm: llm);
    final docprompt = PromptTemplate.fromTemplate(
      'Content: {page_content}\nSource: {source}',
    );
    final finalQAChain = StuffDocumentsChain(
      llmChain: qaChain,
      documentPrompt: docprompt,
    );
    final retrievalQA = RetrievalQAChain(
      retriever: listVector.asRetriever(),
      combineDocumentsChain: finalQAChain,
    );

    final res = await retrievalQA(message);
    print('query');
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .collection('summarize')
        .doc(widget.chatTitleID)
        .collection("QuestionAnswering")
        .add({
      "createdAt": Timestamp.now(),
      "Human": message.trim(),
      "AI": res["result"].toString().trim(),
      'totalTokens': 0,
    });
  }

  void _uploadedFile(String path) async {
    setState(() {
      _isLoading = true;
    });
    TextLoader loader = TextLoader(path);
    const textSplitter = RecursiveCharacterTextSplitter();
    final docs = await loader.load();
    final docsChunks = textSplitter.splitDocuments(docs);
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

    final embeddings = OpenAIEmbeddings(apiKey: widget.apiKey);
    final docSearch = await MemoryVectorStore.fromDocuments(
      documents: textsWithSources,
      embeddings: embeddings,
    );
    print('Finish Embeddings');
    for (var element in docSearch.memoryVectors) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.uid)
          .collection('summarize')
          .doc(widget.chatTitleID)
          .collection("embeddedVectors")
          .add({
        "content": element.content.trim(),
        "embed": element.embedding,
        'metadata': element.metadata
      });
    }
    print('Uploaded Embeddings to FireStore');
    // listVector.
    final llm = ChatOpenAI(
        temperature: 0, apiKey: widget.apiKey, model: 'gpt-3.5-turbo-16k-0613');
    //// summarize
    final docPrompt = PromptTemplate.fromTemplate(summarize_template);
    final summarizeChain = SummarizeChain.stuff(
      llm: llm,
      promptTemplate: docPrompt,
    );

    final summary = await summarizeChain.run(docsChunks);
    print(summary);
    print('-----------');
    final re = RegExp(r'((Question)|(question)|(QUESTION))\W\d\W');
    final suggestList = summary.split(re);
    final sumaryContent = suggestList.removeAt(0);
    print(sumaryContent);
    List topicSummary =
        sumaryContent.split(RegExp(r'((SUMMARY)|(summary)|(Summary))\W*'));
    topicSummary.removeLast();
    String topic = topicSummary.removeAt(0);
    topicSummary = topic.split(RegExp(r'((topic)|(Topic)|(TOPIC))\W*'));
    topic = topicSummary.removeLast();
    //  = topic.replaceFirstMapped(
    // RegExp(r'((topic)|(Topic)|(TOPIC))\W*'), (m) => '');

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .collection('summarize')
        .doc(widget.chatTitleID)
        .update(
      {
        "FilePath": path,
        'chatTitle': topic.trim(),
        "modifiedAt": Timestamp.now(),
      },
    );

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .collection('summarize')
        .doc(widget.chatTitleID)
        .collection('QuestionAnswering')
        .add({
      "AI": sumaryContent.trim(),
      'Human': '',
      'totalTokens': 0,
      "createdAt": Timestamp.now(),
    });

    for (var i in suggestList) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.uid)
          .collection('summarize')
          .doc(widget.chatTitleID)
          .collection("suggestion")
          .add({
        "suggestQuestion": i,
        "createdAt": Timestamp.now(),
      });
    }
    print('Uploaded Summarize');
    setState(() {
      widget.hasFile = true;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<SuggestModel> suggestList = ref.watch(suggestProvider);
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(widget.uid)
            .collection('summarize')
            .doc(widget.chatTitleID)
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
              return Scaffold(
                  appBar: ConfigAppBar(title: widget.chatTitle),
                  body: const Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Color.fromARGB(255, 255, 246, 246),
                    ),
                  ));
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
                  body: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Color.fromARGB(255, 255, 246, 246),
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: Center(
                                child: ElevatedButton.icon(
                                  style: ButtonStyle(
                                    minimumSize:
                                        MaterialStateProperty.all<Size>(
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

                                    final path = file.path;
                                    _uploadedFile(
                                      path!,
                                    );
                                  },
                                ),
                              ),
                            ),
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
                appBar: ConfigAppBar(title: widget.chatTitle),
                body: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Color.fromARGB(255, 255, 246, 246),
                        ),
                      )
                    : Column(
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
                                    timeStamp: DateFormat.yMMMd()
                                        .add_jm()
                                        .format(DateTime.parse(
                                            chatMessage["createdAt"]
                                                .toDate()
                                                .toString())),
                                    shouldAnimate: lengthHistory < 1
                                        ? lengthHistory == index
                                        : lengthHistory - 1 == index,
                                  );
                                }),
                          ),
                          ListView.builder(
                            itemCount: suggestList.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              return ActionChip(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 8),
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.07),
                                label: Container(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.7),
                                    child: Text(
                                      suggestList[index]
                                          .suggestQuestion!
                                          .trim(),
                                      textScaleFactor: 0.85,
                                      softWrap: true,
                                      maxLines: 2,
                                    )),
                                shape: const StadiumBorder(side: BorderSide()),
                                onPressed: () async {
                                  documentQA(
                                      suggestList[index].suggestQuestion!);

                                  await FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(widget.uid)
                                      .collection("summarize")
                                      .doc(widget.chatTitleID)
                                      .collection('suggestion')
                                      .doc(suggestList[index].id)
                                      .delete()
                                      .then((value) => print("Suggest Deleted"))
                                      .catchError((error) =>
                                          print("Failed to delete: $error"));
                                  setState(() {
                                    suggestList.removeAt(index);
                                  });
                                },
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: TextAndVoiceField(
                              uid: widget.uid,
                              userName: widget.userName,
                              apiKey: widget.apiKey,
                              memory: _memoryBuffer,
                              taskMode: 'summarize',
                              chatID: widget.chatTitleID,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
              );
            case ConnectionState.done:
              break;
          }
          return const Center(child: Text('error'));
        });
  }
}
