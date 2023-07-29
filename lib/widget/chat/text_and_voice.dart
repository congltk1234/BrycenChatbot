import 'package:flutter/material.dart';
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

  const TextAndVoiceField({
    super.key,
    required String uid,
    required String apiKey,
    required String userName,
    required String memory,
  })  : _initUID = uid,
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
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget._initUID)
        .collection("chat")
        .add({
      "text": message,
      "createdAt": Timestamp.now(),
      "isUser": true,
    });

    /// Bot Response Chat GPT here
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget._initUID)
        .collection("chat")
        .add({
      "text": 'Bot Response: $message',
      "createdAt": Timestamp.now(),
      "isUser": false,
    });

//// Update memory
    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget._initUID)
        .update({
      "memory": "${widget._memory}\nHuman:$message\nAI:Bot Response $message"
    });
    // Here's a conversation between ${widget._initUsername} with AI:\n
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
