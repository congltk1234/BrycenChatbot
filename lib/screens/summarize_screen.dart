// ignore_for_file: avoid_print

import 'dart:io';

import 'package:brycen_chatbot/widget/internet_error.dart';
import 'package:connection_notifier/connection_notifier.dart';

import '../const/prompt.dart';
import '../models/suggestQuestion.dart';
import '../providers/suggest_provider.dart';
import '../services/file_handler.dart';
import '../widget/app_bar.dart';
import '../widget/chat/chat_item.dart';
import '../widget/chat/text_and_voice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart' as langOpenAI;
import 'package:collection/collection.dart';
import 'package:open_file/open_file.dart';

// ignore: must_be_immutable
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
  var _suggestLoading = false;
  late ScrollController _listScrollController;
  final bool _needsScroll = true;
  late FocusNode focusNode;

  @override
  void initState() {
    _listScrollController = ScrollController();
    focusNode = FocusNode();
    print(widget.chatTitleID);
    ref
        .read(suggestProvider.notifier)
        .fetchDatafromFireStore(widget.uid, widget.chatTitleID);
    Directory('/data/user/0/com.example.brycen_chatbot/cache/file_picker/')
        .create(recursive: true);

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
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut);
  }

  void notify(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        content: Text('$message...'),
      ),
    );
  }

  void documentQA(String message) async {
    setState(() {
      _suggestLoading = true;
    });
    final embeddings = langOpenAI.OpenAIEmbeddings(apiKey: widget.apiKey);
    final llm = langOpenAI.ChatOpenAI(
        apiKey: widget.apiKey, model: 'gpt-3.5-turbo-16k-0613');

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

    final qaChain = langOpenAI.OpenAIQAWithSourcesChain(llm: llm);
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
    setState(() {
      _suggestLoading = false;
    });
  }

  Future<void> _uploadedFile(String path, String url) async {
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
    final embeddings = langOpenAI.OpenAIEmbeddings(apiKey: widget.apiKey);
    final docSearch = await MemoryVectorStore.fromDocuments(
      documents: textsWithSources,
      embeddings: embeddings,
    );
    notify('Store Document Embeddings...');

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
    // listVector.
    final llm = langOpenAI.ChatOpenAI(
        temperature: 0.2,
        apiKey: widget.apiKey,
        model: 'gpt-3.5-turbo-16k-0613');
    //// summarize
    final docPrompt = PromptTemplate.fromTemplate(summarize_template);
    final summarizeChain = SummarizeChain.stuff(
      llm: llm,
      promptTemplate: docPrompt,
    );
    final summary = await summarizeChain.run(docsChunks);
    notify('Summarize Document...');

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
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.uid)
        .collection('summarize')
        .doc(widget.chatTitleID)
        .update(
      {
        'url': url,
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
    notify('Parsing and Stored response...');

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
    setState(() {
      widget.hasFile = true;
      _isLoading = false;
      ref
          .read(suggestProvider.notifier)
          .fetchDatafromFireStore(widget.uid, widget.chatTitleID);
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
                  body: ConnectionNotifierToggler(
                    onConnectionStatusChanged: (connected) {
                      if (connected == null) return;
                    },
                    disconnected: const InternetError(),
                    connected: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              backgroundColor:
                                  Color.fromARGB(255, 255, 246, 246),
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
                                      final result =
                                          await FilePicker.platform.pickFiles(
                                        dialogTitle: "Only Text and Audio file",
                                        type: FileType.custom,
                                        allowedExtensions: [
                                          'txt',
                                          'pdf',
                                          'docx',
                                          'mp3',
                                          'wav',
                                          'mpga',
                                          'mpeg'
                                        ],
                                      );
                                      if (result == null) return;

                                      PlatformFile file = result.files.first;
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      String filename =
                                          file.name.split('.').first;
                                      String fileContent;
                                      switch (file.extension) {
                                        case 'txt':
                                          notify(
                                              'Upload file to Firebase Storage...');
                                          final url = await uploadFile(
                                              widget.uid, File(file.path!));
                                          _uploadedFile(file.path!, url);
                                          await FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(widget.uid)
                                              .collection('summarize')
                                              .doc(widget.chatTitleID)
                                              .update(
                                            {
                                              "FilePath": file.path!,
                                            },
                                          );
                                          break;
                                        case 'docx':
                                          fileContent =
                                              await doc2text(file.path!);
                                          notify('Converting docx to text...');

                                          final myFile = File(
                                              '/data/user/0/com.example.brycen_chatbot/cache/file_picker/$filename.txt');
                                          await myFile
                                              .writeAsString(fileContent)
                                              .then((value) => notify(
                                                  'Upload file to Firebase Storage...'));

                                          final url = await uploadFile(
                                              widget.uid, File(file.path!));
                                          _uploadedFile(myFile.path, url);

                                          await FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(widget.uid)
                                              .collection('summarize')
                                              .doc(widget.chatTitleID)
                                              .update(
                                            {
                                              "FilePath": file.path!,
                                            },
                                          );
                                          break;
                                        case 'pdf':
                                          fileContent =
                                              await pdf2text(file.path!);
                                          notify('Extracting text from pdf...');

                                          final myFile = File(
                                              '/data/user/0/com.example.brycen_chatbot/cache/file_picker/$filename.txt');
                                          await myFile
                                              .writeAsString(fileContent)
                                              .then((value) => notify(
                                                  'Upload file to Firebase Storage...'));
                                          final url = await uploadFile(
                                              widget.uid, File(file.path!));
                                          _uploadedFile(myFile.path, url);
                                          await FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(widget.uid)
                                              .collection('summarize')
                                              .doc(widget.chatTitleID)
                                              .update(
                                            {
                                              "FilePath": file.path!,
                                            },
                                          );
                                          await FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(widget.uid)
                                              .collection('summarize')
                                              .doc(widget.chatTitleID)
                                              .update(
                                            {
                                              "FilePath": file.path!,
                                            },
                                          );
                                          break;
                                        case 'mpga':
                                        case 'mpeg':
                                        case 'wav':
                                        case 'mp3':
                                          notify(
                                              'Calling Whisper for speech to text...');
                                          fileContent = await speech2text(
                                              widget.apiKey, file.path!);

                                          final myFile = File(
                                              '/data/user/0/com.example.brycen_chatbot/cache/file_picker/${filename}_script.txt');
                                          await myFile
                                              .writeAsString(fileContent)
                                              .then((value) => notify(
                                                  'Upload file to Firebase Storage...'));
                                          final url = await uploadFile(
                                              widget.uid, myFile);
                                          _uploadedFile(myFile.path, url);

                                          await FirebaseFirestore.instance
                                              .collection("users")
                                              .doc(widget.uid)
                                              .collection('summarize')
                                              .doc(widget.chatTitleID)
                                              .update(
                                            {
                                              "FilePath": myFile.path,
                                            },
                                          );
                                          break;
                                        default:
                                          print('No valid file');
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              }
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

              if (_needsScroll) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => scrollListToEND());
                // _needsScroll = false;
              }
              return Scaffold(
                appBar: ConfigAppBar(title: widget.chatTitle),
                body: ConnectionNotifierToggler(
                  onConnectionStatusChanged: (connected) {
                    if (connected == null) return;
                  },
                  disconnected: const InternetError(),
                  connected: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Color.fromARGB(255, 255, 246, 246),
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: Stack(
                                alignment: AlignmentDirectional.bottomCenter,
                                children: [
                                  Column(
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                            controller: _listScrollController,
                                            itemCount: lengthHistory,
                                            itemBuilder: (context, index) {
                                              final chatMessage =
                                                  loadedMessages[index].data();
                                              return ChatItem(
                                                humanMessage:
                                                    chatMessage["Human"],
                                                botResponse: chatMessage["AI"],
                                                tokens:
                                                    chatMessage["totalTokens"],
                                                timeStamp: DateFormat.yMMMd()
                                                    .add_jm()
                                                    .format(DateTime.parse(
                                                        chatMessage["createdAt"]
                                                            .toDate()
                                                            .toString())),
                                                shouldAnimate: false,
                                              );
                                            }),
                                      ),
                                      ListView.builder(
                                        itemCount: suggestList.length,
                                        shrinkWrap: true,
                                        itemBuilder:
                                            (BuildContext context, int index) {
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
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.65),
                                                child: Text(
                                                  suggestList[index]
                                                      .suggestQuestion!
                                                      .trim(),
                                                  textScaleFactor: 0.85,
                                                  softWrap: true,
                                                  maxLines: 2,
                                                )),
                                            shape: const StadiumBorder(
                                                side: BorderSide()),
                                            onPressed: _suggestLoading
                                                ? null
                                                : () async {
                                                    documentQA(
                                                        suggestList[index]
                                                            .suggestQuestion!);
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("users")
                                                        .doc(widget.uid)
                                                        .collection("summarize")
                                                        .doc(widget.chatTitleID)
                                                        .collection(
                                                            'suggestion')
                                                        .doc(suggestList[index]
                                                            .id)
                                                        .delete()
                                                        .then((value) => print(
                                                            "Suggest Deleted"))
                                                        .catchError((error) =>
                                                            print(
                                                                "Failed to delete: $error"));
                                                    setState(
                                                      () {
                                                        suggestList
                                                            .removeAt(index);
                                                      },
                                                    );
                                                  },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    left: 5,
                                    child: FloatingActionButton.small(
                                      child: const Icon(
                                        Icons.file_present_rounded,
                                      ),
                                      onPressed: () async {
                                        final fileData = await FirebaseFirestore
                                            .instance
                                            .collection("users")
                                            .doc(widget.uid)
                                            .collection('summarize')
                                            .doc(widget.chatTitleID)
                                            .get();
                                        final url = fileData.data()!['url'];
                                        final path =
                                            fileData.data()!['FilePath'];
                                        final fileExist =
                                            await File(path).exists();
                                        switch (fileExist) {
                                          case false:
                                            print('need dowwnload');
                                            await downloadFile(url, path);
                                            continue open;
                                          open:
                                          case true:
                                            OpenFile.open(path);
                                            print('read');
                                          default:
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextAndVoiceField(
                                uid: widget.uid,
                                userName: widget.userName,
                                apiKey: widget.apiKey,
                                memory: _memoryBuffer,
                                taskMode: 'summarize',
                                chatID: widget.chatTitleID,
                              ),
                            ),
                          ],
                        ),
                ),
              );
            case ConnectionState.done:
              break;
          }
          return const Center(child: Text('error'));
        });
  }
}
