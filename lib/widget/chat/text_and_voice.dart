import 'package:flutter/material.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:brycen_chatbot/services/voice_handle.dart';
import 'package:brycen_chatbot/widget/chat/toggle_button.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart' as langOpenAI;

enum InputMode {
  text,
  voice,
}

class TextAndVoiceField extends StatefulWidget {
  final String _initUID;
  final String _initAPIKey;
  final String _initUsername;
  final String _memory;
  final String _taskMode;
  // final List<dynamic> _memory;
  String _chatID;
  TextAndVoiceField({
    super.key,
    required String uid,
    required String apiKey,
    required String userName,
    required String memory,
    required String taskMode,
    required String chatID,
    // required List<dynamic> memory,
  })  : _initUID = uid,
        _initAPIKey = apiKey,
        _initUsername = userName,
        _memory = memory,
        _taskMode = taskMode,
        _chatID = chatID;

  @override
  State<TextAndVoiceField> createState() => _TextAndVoiceFieldState();
}

class _TextAndVoiceFieldState extends State<TextAndVoiceField> {
  InputMode _inputMode = InputMode.voice;
  final _messageController = TextEditingController();
  var _isReplying = false;
  var _isListening = false;
  final VoiceHandler voiceHandler = VoiceHandler();

  @override
  void initState() {
    voiceHandler.initSpeech();
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            onChanged: (value) {
              value.isNotEmpty
                  ? setInputMode(InputMode.text)
                  : setInputMode(InputMode.voice);
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        ToggleButton(
          inputMode: _inputMode,
          isReplying: _isReplying,
          isListening: _isListening,
          sendTextMessage: () {
            final message = _messageController.text;
            _messageController.clear();

            /// Switch Case
            if (widget._taskMode == 'chat') {
              sendTextMessage(message);
            }
            if (widget._taskMode == 'summarize') {
              documentQA(message);
            }

            setState(() {
              _messageController.clear();
              setInputMode(InputMode.voice);
            });
          },
          sendVoiceMessage: () {
            sendVoiceMessage();
          },
        ),
      ],
    );
  }

  void setInputMode(InputMode inputMode) {
    setState(() {
      _inputMode = inputMode;
    });
  }

  void sendVoiceMessage() async {
    if (!voiceHandler.isEnabled) {
      print('Not supported');
      return;
    }
    if (voiceHandler.speechToText.isListening) {
      await voiceHandler.stopListening();
      setListeningState(false);
    } else {
      setListeningState(true);
      final result = await voiceHandler.startListening();
      setListeningState(false);
      setState(() {
        _messageController.text = result;
        setInputMode(InputMode.text);
      });
    }
  }

  // void check

  void sendTextMessage(String message) async {
    setReplyingState(true);
// prompt
    final prompt =
        "Here's a conversation between user ${widget._initUsername} and AI: \n From given context \n ${widget._memory} \n response this message: $message";
    print('send msg');

    /// Bot Response Chat GPT here
    OpenAI.apiKey = widget._initAPIKey;
    final OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo",
      messages: [
        OpenAIChatCompletionChoiceMessageModel(
          content: prompt,
          role: OpenAIChatMessageRole.user,
        ),
      ],
    );
    final listHistory = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget._initUID)
        .collection("chat")
        .doc(widget._chatID)
        .collection('chat_history')
        .get();
    if (listHistory.docs.length < 2) {
      final OpenAIChatCompletionModel topic = await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            content:
                "Short Key Topic of given context (No more than 10 words):  \nHuman:$message\nAI:${chatCompletion.choices[0].message.content}",
            role: OpenAIChatMessageRole.user,
          ),
        ],
      );
      print(topic.choices[0].message.content);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget._initUID)
          .collection('chat')
          .doc(widget._chatID)
          .update({
        "chatTitle": topic.choices[0].message.content,
        "memory":
            "${widget._memory}\nHuman:$message\nAI:${chatCompletion.choices[0].message.content}"
      });
    }
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget._initUID)
        .collection("chat")
        .doc(widget._chatID)
        .collection('chat_history')
        .add({
      "createdAt": Timestamp.now(),
      "Human": message.trim(),
      "AI": chatCompletion.choices[0].message.content.trim(),
      'totalTokens': chatCompletion.usage.totalTokens,
    });
    //// Update memory
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget._initUID)
        .collection('chat')
        .doc(widget._chatID)
        .update({
      "memory":
          "${widget._memory}\nHuman:$message\nAI:${chatCompletion.choices[0].message.content}"
    });
    setReplyingState(false);
  }

  void documentQA(String message) async {
    setReplyingState(true);

    final embeddings = langOpenAI.OpenAIEmbeddings(apiKey: widget._initAPIKey);
    final llm = langOpenAI.ChatOpenAI(
        apiKey: widget._initAPIKey, model: 'gpt-3.5-turbo-16k-0613');

    final storedVectors = await FirebaseFirestore.instance
        .collection("users")
        .doc(widget._initUID)
        .collection('summarize')
        .doc(widget._chatID)
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
        .doc(widget._initUID)
        .collection('summarize')
        .doc(widget._chatID)
        .collection("QuestionAnswering")
        .add({
      "createdAt": Timestamp.now(),
      "Human": message,
      "AI": res["result"].toString(),
      'totalTokens': 0,
    });

    setReplyingState(false);
  }

  void setReplyingState(bool isReplying) {
    setState(() {
      _isReplying = isReplying;
    });
  }

  void setListeningState(bool isListening) {
    setState(() {
      _isListening = isListening;
    });
  }
}
