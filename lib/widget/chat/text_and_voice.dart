import 'package:flutter/material.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:brycen_chatbot/services/voice_handle.dart';
import 'package:brycen_chatbot/widget/chat/toggle_button.dart';

enum InputMode {
  text,
  voice,
}

class TextAndVoiceField extends StatefulWidget {
  final String _initUID;
  final String _initAPIKey;
  final String _initUsername;
  final String _memory;
  // final List<dynamic> _memory;

  const TextAndVoiceField(
      {super.key,
      required String uid,
      required String apiKey,
      required String userName,
      required String memory
      // required List<dynamic> memory,
      })
      : _initUID = uid,
        _initAPIKey = apiKey,
        _initUsername = userName,
        _memory = memory;
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
            sendTextMessage(message);
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

  void sendTextMessage(String message) async {
    setReplyingState(true);
// prompt
    final prompt =
        "Here's a conversation between user ${widget._initUsername} with AI: ${widget._memory} .\n From given context, response this message: $message";

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

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget._initUID)
        .collection("chat")
        .add({
      "createdAt": Timestamp.now(),
      "Human": message,
      "AI": chatCompletion.choices[0].message.content,
      'totalTokens': chatCompletion.usage.totalTokens,
    });

//// Update memory
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget._initUID)
        .update({
      "memory":
          "${widget._memory}\nHuman:$message\nAI:${chatCompletion.choices[0].message.content}"
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